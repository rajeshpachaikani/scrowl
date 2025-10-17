const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

admin.initializeApp();

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(functions.config().gemini.apikey || process.env.GEMINI_API_KEY);

/**
 * Generate trivia content using Gemini AI
 * Called via HTTPS request
 */
exports.generateTrivia = functions.https.onCall(async (data, context) => {
  const { category, count = 5 } = data;

  if (!category) {
    throw new functions.https.HttpsError('invalid-argument', 'Category is required');
  }

  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    const prompt = `Generate ${count} interesting, fact-checked trivia questions and answers about ${category}. 
Format the response as a JSON array with objects containing:
- question: A clear, engaging question
- answer: A detailed, accurate answer
- tags: An array of 2-3 relevant tags
- source: A brief source reference (can be general like "Scientific consensus" or "Historical records")

Make the trivia educational, interesting, and appropriate for a general audience. Ensure all facts are accurate and verifiable.`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // Try to extract JSON from the response
    let triviaData;
    try {
      // Remove markdown code blocks if present
      const jsonMatch = text.match(/```json\s*([\s\S]*?)\s*```/) || text.match(/```\s*([\s\S]*?)\s*```/);
      const jsonText = jsonMatch ? jsonMatch[1] : text;
      triviaData = JSON.parse(jsonText);
    } catch (parseError) {
      console.error('Failed to parse AI response:', text);
      throw new functions.https.HttpsError('internal', 'Failed to parse AI response');
    }

    // Store generated trivia in Firestore
    const batch = admin.firestore().batch();
    const triviaRef = admin.firestore().collection('trivia');

    triviaData.forEach((trivia) => {
      const docRef = triviaRef.doc();
      batch.set(docRef, {
        question: trivia.question,
        answer: trivia.answer,
        category: category,
        tags: trivia.tags || [],
        source: trivia.source || 'AI Generated',
        isSponsored: false,
        likes: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();

    return {
      success: true,
      count: triviaData.length,
      message: `Generated ${triviaData.length} trivia items for ${category}`,
    };
  } catch (error) {
    console.error('Error generating trivia:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Scheduled function to generate daily trivia
 * Runs every day at midnight UTC
 */
exports.generateDailyTrivia = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    const categories = [
      'science',
      'technology',
      'history',
      'geography',
      'arts',
      'sports',
      'music',
      'nature',
      'space',
      'literature',
      'food',
      'movies',
    ];

    try {
      const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

      for (const category of categories) {
        const prompt = `Generate 3 interesting, fact-checked trivia questions and answers about ${category}. 
Format the response as a JSON array with objects containing:
- question: A clear, engaging question
- answer: A detailed, accurate answer
- tags: An array of 2-3 relevant tags
- source: A brief source reference

Make the trivia educational, interesting, and appropriate for a general audience.`;

        try {
          const result = await model.generateContent(prompt);
          const response = await result.response;
          const text = response.text();

          let triviaData;
          try {
            const jsonMatch = text.match(/```json\s*([\s\S]*?)\s*```/) || text.match(/```\s*([\s\S]*?)\s*```/);
            const jsonText = jsonMatch ? jsonMatch[1] : text;
            triviaData = JSON.parse(jsonText);
          } catch (parseError) {
            console.error(`Failed to parse AI response for ${category}`);
            continue;
          }

          // Store in Firestore
          const batch = admin.firestore().batch();
          const triviaRef = admin.firestore().collection('trivia');

          triviaData.forEach((trivia) => {
            const docRef = triviaRef.doc();
            batch.set(docRef, {
              question: trivia.question,
              answer: trivia.answer,
              category: category,
              tags: trivia.tags || [],
              source: trivia.source || 'AI Generated',
              isSponsored: false,
              likes: 0,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          });

          await batch.commit();
          console.log(`Generated ${triviaData.length} trivia items for ${category}`);
        } catch (error) {
          console.error(`Error generating trivia for ${category}:`, error);
        }

        // Add a small delay to avoid rate limiting
        await new Promise((resolve) => setTimeout(resolve, 2000));
      }

      return null;
    } catch (error) {
      console.error('Error in generateDailyTrivia:', error);
      return null;
    }
  });

/**
 * Update user ranking when reward points change
 */
exports.updateUserRanking = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if reward points changed
    if (beforeData.rewardPoints !== afterData.rewardPoints) {
      const userId = context.params.userId;
      const newPoints = afterData.rewardPoints;

      // Calculate rank
      const rankThresholds = {
        'Beginner': 0,
        'Explorer': 50,
        'Scholar': 200,
        'Expert': 500,
        'Master': 1000,
        'Legend': 2500,
      };

      let rank = 0;
      for (const [title, threshold] of Object.entries(rankThresholds)) {
        if (newPoints >= threshold) {
          rank++;
        }
      }

      // Update user rank
      await change.after.ref.update({ rank });

      // Store in rankings collection for leaderboard
      const rankingRef = admin.firestore().collection('rankings').doc(userId);
      await rankingRef.set({
        userId: userId,
        username: afterData.username,
        rewardPoints: newPoints,
        rank: rank,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    return null;
  });

/**
 * Clean up old trivia (optional maintenance function)
 * Removes trivia older than 90 days
 */
exports.cleanupOldTrivia = functions.pubsub
  .schedule('0 2 * * 0')
  .timeZone('UTC')
  .onRun(async (context) => {
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    const snapshot = await admin
      .firestore()
      .collection('trivia')
      .where('createdAt', '<', ninetyDaysAgo)
      .limit(500)
      .get();

    if (snapshot.empty) {
      console.log('No old trivia to delete');
      return null;
    }

    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${snapshot.size} old trivia items`);
    return null;
  });
