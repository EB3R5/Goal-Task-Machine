
function getService() {
  // Log a message to indicate that the function is being executed
  Logger.log("Executing getService");
  var email = "firebase-adminsdk-h3we3@goal-task-machine.iam.gserviceaccount.com"
  var key = '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCedLnebbrXFDep\nL8tdFZkA3gufqrNLZ64sqBelanvDFYfd6si4jllVbD+qGbzA6sbCxNY2i/zHwn1K\n5c10ENBv2U8Qps/gvK13du7BVh5gvr1COXTlEHjD7NHjW8+7ngRZzjmvbPgcFfaa\ndiThJm9rAzxOpYeqbnembFGIWJdnCRu4iN5//gGQ1nbpEkmm4sgoS1IBUgzUla5U\n9s7P5SN254M9eHVURhLrFO3EYbIbebJbLxev6//1OA+6D+FtCPw6DbNHLndKNtpU\nFF0q6MHQzuhEIfkQe5+BY44XVK/2277JO+bSzf/1a/klVyki7jdRmBpDaOAci2Y9\n1hZ7CyRtAgMBAAECggEAM/FosrD+1B2VB3ma7Sc00lN3tP4Eq13P+2SY58lJy9Al\ni0o5RUKopzeGgTDRrt3njRZwcE4gba1kXCaL3JXcdiXi5L8CGxZOuQA8URV1fNpZ\n+TkTiDmHlRZvUVwZ81Nf8r6HK2oJxU8v2T+MZGAwmwBjBxb9K5Ht2Bje+1arPwN5\noKpB/wuxlU1Ilc5FGVPIAnJD0KJ1njRR89vq9t7NlSV6uYoxiHnIK7RUwP5l8oaI\nYvDJKxOroYedwCYW5328Tw83Nj9Dm03018zDfNEaiYhJh+0x6zrGGWC2FVSSKYbC\ni1m5ikTUMZk4Ll9S7CccGbQlx5JzHyIMY2X49Fo1kwKBgQDUJIIixqvDobOF1M5a\nxklLJLFMg/g+82rFuWi5d1U3jDmJhgfjY/wJGMYiWMR07LX8389g1X8NGH5A6d5n\n/wYcVzOU7JJ9DbbLWsOQVHlXhX6XxOlYeXay7P0NPuqupgGCxW8OoxljZC34i2pD\nAFzlkStq+sLoM8T/x3w1/Df86wKBgQC/NuQppwig6NQYFeTFqIeZJTOrtvxd7Pce\nibG9D9pQgFVbVtMlM7Z8OO90R6TCPrVf91jfhMS57784bDT9LGS4X+3m7TIcRh8q\nsA9b/bKftml2cPkIZeqjo6lIHkCslcg/Bz8ms6X5G9uGMRrr5ZGSkM+MCITbbcNK\nNba3mfMuBwKBgQDB1Y3WiqKcwJ3Qla3qwSxs7VzWpepoUm9ntE5c0A1cENLttjp0\n6YF7Kli3P1ZZ44MxR6orN0e8RnnthALEEP+bW4307+e1PZec3RS9RoIMlxwhPjlb\nrrfnKqTYunkiFOpie1VLEXl8GCfs5i20hJtc4rTCLddy5QKGFtaGWSsq+wKBgF7S\n5csSHmFNlQBsuwqaTMRRgpJBKF2byeDG//F2Dxmkyq+FGyhzwKdRxM2xSa9aUa/J\nhbUyrixXDEj6wDxc64XTbLL8JcGHtKUCsls4MICrgRlPZPAZOobz/lrZRdFQZgF7\nooGazU//1JlzeJpLOimozoPvJZN7l0ER6g6atdG5AoGAJpafsCNJ0gx8u+mfGbuY\nR2hDy4fJjvElgKg90NZKbUD9KanBvDnsHt5JOMGIPLR1cpIiD4FGgDyq1g0RmaXB\nnysni38lTghjQXvcvc7RPVrQoBMzwhtdbFgBAPXxhaGkbE+ORHI7yGl7YiwI6mC0\nvq9kV/HuJ06UgWvZRB+USo4=\n-----END PRIVATE KEY-----\n'
  var projectId = "goal-task-machine"
  return FirestoreApp.getFirestore(email,key,projectId)
}




function logAllData() {
  const firestore = getService();
  var sheetName = "Actions Ontology";
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);

  if (!sheet) {
    Logger.log("Sheet not found: " + sheetName);
    return;
  }

  // Get the last row and last column with data
  var lastRow = sheet.getLastRow();
  var lastCol = sheet.getLastColumn();

  // Specify the range starting from row 2 to the last row and all columns
  var dataRange = sheet.getRange(2, 1, lastRow - 1, lastCol);
  var sheetData = dataRange.getValues();

  // Iterate through each row
  for (var i = 0; i < sheetData.length; i++) {
    // Check if the second column is not empty
    if (sheetData[i][1] !== '') {
      // Initialize data object
      var data = {
        Hierarchy: sheetData[i][0],
        Action: sheetData[i][1],
        Location: sheetData[i][2],
        Items: sheetData[i][3],
        Cadence: sheetData[i][4],
        Description: sheetData[i][5],
        Time: sheetData[i][6],
        Condition: sheetData[i][7]
      };

      // Log the data for the current row
      Logger.log(data);

      try {
        firestore.createDocument("Actions Ontology", data);
        Logger.log("Document created successfully for row " + (i + 2));
      } catch (e) {
        Logger.log("Error:", e.toString());
        Logger.log("Stack Trace:", e.stack);
      }
    }
  }

  Logger.log("Data logging complete.");
}
