// Generated by CoffeeScript 1.3.3
(function() {
  var ToonRenderPass;

  ToonRenderPass = (function() {

    ToonRenderPass.TOON1 = "toon1";

    ToonRenderPass.TOON2 = "toon2";

    ToonRenderPass.HATCHING = "hatching";

    ToonRenderPass.DOTTED = "dotted";

    function ToonRenderPass(scene, camera, type, uniforms, clearColor, clearAlpha) {
      var i, shader;
      this.scene = scene;
      this.camera = camera;
      this.clearColor = clearColor;
      this.clearAlpha = clearAlpha;
      this.enabled = true;
      this.clear = true;
      this.needsSwap = false;
      if (type === !ToonRenderPass.TOON1 || type === !ToonRenderPass.TOON2 || type === !ToonRenderPass.HATCHING || type === !ToonRenderPass.DOTTED) {
        return null;
      }
      shader = THREE.ShaderToon[type];
      this.uniforms = THREE.UniformsUtils.clone(shader.uniforms);
      for (i in uniforms) {
        if (this.uniforms[i] != null) {
          this.uniforms[i].value = uniforms[i];
        }
      }
      this.material = new THREE.ShaderMaterial({
        uniforms: this.uniforms,
        vertexShader: shader.vertexShader,
        fragmentShader: shader.fragmentShader
      });
    }

    ToonRenderPass.prototype.render = function(renderer, writeBuffer, readBuffer, delta) {
      if (this.material != null) {
        this.scene.overrideMaterial = this.material;
      }
      if (this.clearColor) {
        this.oldClearColor.copy(renderer.getClearColor());
        this.oldClearAlpha = renderer.getClearAlpha();
        renderer.setClearColor(this.clearColor, this.clearAlpha);
      }
      renderer.render(this.scene, this.camera, readBuffer, this.clear);
      if (this.clearColor) {
        renderer.setClearColor(this.oldClearColor, this.oldClearAlpha);
      }
      return this.scene.overrideMaterial = null;
    };

    return ToonRenderPass;

  })();

  this.ToonRenderPass = ToonRenderPass;

}).call(this);
