function runManually() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var list = ss.getSheetByName('List');
  var ontology = ss.getSheetByName('Actions Ontology');
  var healthTransactions = ss.getSheetByName('Priority');
  
  // Get all the data from the List sheet starting from row 4
  var listData = list.getRange("A3:D" + list.getLastRow()).getValues();
  
  // Find the last non-empty row in the 'Priority' sheet
  var startRow = healthTransactions.getLastRow() + 1;
  
  // Loop through the data to find checkboxes that are checked
  for (var i = 0; i < listData.length; i++) {
    if (listData[i][0] === true) {
      var keywordC = listData[i][2]; // Get data from column C in 'List'
      var data = ontology.getDataRange().getValues();
      
      // Filter data from 'Actions Ontology' based on data from column C
      var filteredData = data.filter(function(row) {
        return row[2] == keywordC; // Assuming column C is the third column (index 2)
      });
      
      // Create an array for all columns from 'Actions Ontology' (A to Q)
      var appendedData = filteredData.map(function(row) {
        var ontologyColumns = row.slice(0, 17); // Columns A to Q
        return ontologyColumns; // Exclude the timestamp columns
      });
      healthTransactions.getRange(startRow, 3, appendedData.length, appendedData[0].length).setValues(appendedData);
      
      // Update the starting row for the next keyword
      startRow += appendedData.length;
    }
  }
  
  // Sort the 'Priority' sheet by column C in ascending order
  var rangeToSort = healthTransactions.getRange(2, 3, healthTransactions.getLastRow(), 17); // Assuming 17 columns of data
  rangeToSort.sort(3); // Sorting by column C
}



function clearSheetExceptFirstRow() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName('Priority'); // Change to your sheet name

  // Get the data range of the sheet (excluding the first row)
  var dataRange = sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn());

  // Clear the data in the range
  dataRange.clear();
}

function conditionHistory() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var list = ss.getSheetByName('List');
  var ontology = ss.getSheetByName('Actions Ontology');
  var conditionHistory = ss.getSheetByName('Condition History');

  // Get all the data from the List sheet starting from row 4
  var listData = list.getRange("A3:D" + list.getLastRow()).getValues();

  // Find the last non-empty row in the 'Condition History' sheet
  var startRow = conditionHistory.getLastRow() + 1;

  // Loop through the data to find checkboxes that are checked
  for (var i = 0; i < listData.length; i++) {
    if (listData[i][0] === true) {
      var keywordC = listData[i][2]; // Get data from column C in 'List'
      var keywordB = listData[i][1]; // Get data from column B in 'List'
      var data = ontology.getDataRange().getValues();

      // Filter data from 'Actions Ontology' based on data from column C
      var filteredData = data.filter(function(row) {
        return row[2] == keywordC; // Assuming column C is the third column (index 2)
      });

      // Check if any data was found in the filter
      if (filteredData.length > 0) {
        // Create an array for all columns from 'Actions Ontology' (A to Q)
        var appendedData = filteredData.map(function(row) {
          var ontologyColumns = row.slice(0, 17); // Columns A to Q
          return ontologyColumns; // Exclude the timestamp columns
        });

        // Update the appendedData array to include the value from column B in 'List'
        appendedData.forEach(function(row) {
          row.unshift(keywordB);
        });

        // Paste the data into the 'Condition History' sheet
        conditionHistory.getRange(startRow, 2, appendedData.length, appendedData[0].length).setValues(appendedData);

        // Update the starting row for the next keyword
        startRow += appendedData.length;
      }
    }
  }

  // Sort the 'Condition History' sheet by column C in ascending order
  var rangeToSort = conditionHistory.getRange(2, 3, conditionHistory.getLastRow(), 17); // Assuming 17 columns of data
  rangeToSort.sort(3); // Sorting by column C
}


