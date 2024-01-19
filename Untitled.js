function getService() {
  // Log a message to indicate that the function is being executed
  Logger.log("Executing getService");
  var email = "firebase-import-1@goal-task-machine.iam.gserviceaccount.com"
  var key = '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC43AqhhHo8zgMH\nGyy+k6GLfsS2Ob5glVPGzooA8dgZz+mSi0IEZ8ukeAxy1cGx6YnyOB9RAumEtlNS\nYEGxq5YqrXgSl+hbkKa93/B2vZZckMEEgq+mpmzZe5lOcY7fyn03jh1tm9PmHJ5s\nAA+vaOaRr/Eq/aTbw40TAbBtFxKOA4tVEvtGAbhKgWaVSgpB6oMb207uhZKRSO26\n53y/K3CT7+6+3BaRzxwRX/0sk6gPLGY5e/WQ1RxM4xbBhsqAXYyIzLfEn7veGcZl\n/jdcFRiR60x2UVrGb49pLsT0ddHeahVNPfoeFWiJfQFB3kmTBmEimk8i6QW6pg/n\nc5lY2vxNAgMBAAECggEAOnS6l+DAlsG+i1y4hXtBtk7b/ZO88+XEnDVrxmizoVXx\n0nle4u2/o76ikR2vJodnK8U7ge6d0W2mY4I0w+4yikRYl+iZfXr8f0Z1T9cb2SGd\nJ8P7r4MpIIzJKdkXCQWLGypBfAuusjGSlyxdyWYuoxsz9BhJLYVk8wGxvI1zPJyw\nfG8H0LqV7fywWIKJTBmOMg9x/Xea3NmesLSl/KkYKIQPlOKt4JKUiZreZ01r5Abq\nhoJ16cUZphh0NqlroCD2SzEOrR6bbSedp6d/a1YBc+iwHv3wc/oCQHOmESM/BGa4\nVIutftkzqV9aBhUczqXhTLNHnBHq8nALEEMtwMU/MQKBgQDmuuWdzodX1DdoRmHv\nIMtml2EipJzSytEuZN35zXrfYKuzdKrNhTqzG9giePnK7iaqBYOe3AZhXMwiKaAi\nGWte64e6v4IMIrEQgDFt7jn+hzZZpqgW4YlQxQIPxheZq6cRa+erTWV+YyleERbC\n970L7YDQgX/fpRTnx3hqzPC2JwKBgQDNGwxBpq+CsnCOB+qah1F7ikmZ3yk6EAkF\nt+3beRaKwcQbW8FJAkvo7p7UmN8l/icbDhvcNnmaCjPIeuBatVrAgyOQMHu1nW2d\n8TMhDL662hvr2R9qHWVA7ukU+t2ASzLsOKWWetOPAOKXgwKvUxA2yZ9x4/Lrbbqx\nb2gohNyWawKBgCzFhXrasZ6UWnAMgEJznaR5qWqcgKXSn0aeYghwG/CuhILdF6ur\nt5k7xPPjf60mCzCgw0qXLVHFPQNACoezYQdZMsxFDwolzTADgBPxzyUZva0lzqYp\n+4hFwkGnUbsK+O9Dff/ak+Azg7pyHHWWtwNSgdVz24ldMjJLnY0z2V2vAoGBAJBU\nGTLVfanFsShw76if0jnR3Or3O0aNZBvvCuSm97LamQn7bi7W+93ElGXb0SMmDhSe\nwAIdH0LDLR9FQDz0YxEW9t6PD26Egk9jHGyEUG6h7oXvOojseITR2ZiW02llAUdy\nsSsL8XUu1URyv1/qXn1/McDt+9GpXHdhgvUIUUVTAoGAcsvV6J/hc4Hs3ZRD/+E/\nocej8QbSlbqMFq9hxRurtGHykbBMubPdJuU86gKtFAQjd5tn7tymaSmVjkAwFITu\nFSiehX/m8ekKM6YVTveDJje7v+n7ZBlEfbgOhd3RMgfDCd8+CmPfuYGskjXVKOq/\n87fbJNifS7KnKOfzJz7FBDY=\n-----END PRIVATE KEY-----\n'
  var projectId = "goal-task-machine"
  return FirestoreApp.getFirestore(email,key,projectId)
}


function logFirestoreDataToSheet() {
  const firestore = getService();
  const sheetName = "Sheet1";
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);

    const allDocuments = firestore.getDocuments("Actions Ontology");

    for(var i = 0; i < allDocuments.length; i++){


    var myArray = []; // Array to store document data

    var DocumentID = allDocuments[i].fields["_id"];
   myArray.push([DocumentID].stringValue);
    var Hierarchy = allDocuments[i].fields["Hierarchy"];
    myArray.push(Hierarchy.stringValue);
    var Action = allDocuments[i].fields["Action"];
    myArray.push(Action.stringValue);
    var Location = allDocuments[i].fields["Location"];
    myArray.push(Location.stringValue);
    var Items = allDocuments[i].fields["Items"];
    myArray.push(Items.stringValue);
    var Cadence = allDocuments[i].fields["Cadence"]
    myArray.push(Cadence.stringValue);
    var Description = allDocuments[i].fields["Description"]
    myArray.push(Description.stringValue);
    var Time = allDocuments[i].fields["Time"]
    myArray.push(Time.stringValue);
    var Condition = allDocuments[i].fields["Condition"]
    myArray.push(Condition.stringValue);

      Logger.log(myArray);

    sheet.appendRow(myArray)

    }
}
