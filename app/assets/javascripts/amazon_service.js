$("#fileUploadForm").submit(function() {
  var bucket = new AWS.S3({params: {Bucket: 'test-llegando'}});
  var fileChooser = document.getElementById('file');
  var file = fileChooser.files[0];
  if (file) {
    var params = {Key: file.name, ContentType: file.type, Body: file, 'x-amz-acl': 'public-read'};
    bucket.upload(params).on('httpUploadProgress', function(evt) {
    console.log("Uploaded :: " + parseInt((evt.loaded * 100) / evt.total)+'%');
  }).send(function(err, data) {
    if (err) {
      alert("Error while uploading.");
    } else {
      alert("File uploaded successfully.");
      $.post( "/uploads", { url: data.Location }, function( data ) {
        $( "#response" ).html( "<p>See the file in the following url: <a href="+ data.show_url +">Your File</a></p>" );
      });
    }
  });
}
return false;
});