// Initialize WebGL context
const canvas = document.getElementById('canvas');
const gl = canvas.getContext('webgl');

// Create texture object
const texture = gl.createTexture();
gl.bindTexture(gl.TEXTURE_2D, texture);

// Initialize texture object
gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, canvas.width, canvas.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

// Create Spout receiver object
const receiver = new SpoutReceiver();

// Receive Spout image into texture object
receiver.receiveTexture(texture, function() {
  // Bind texture object to active texture unit
  gl.activeTexture(gl.TEXTURE0);
  gl.bindTexture(gl.TEXTURE_2D, texture);

  // Render Spout image
  gl.drawArrays(gl.TRIANGLES, 0, 6);
});
