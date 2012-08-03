// Generated by CoffeeScript 1.3.3
(function() {
  var init, initEffect, update, windowHeight, windowWidth,
    _this = this;

  $(function() {
    if (Detector.webgl) {
      return init();
    }
  });

  init = function() {
    var geometry, i, l, light, object, st;
    _this.container = $("body");
    _this.areaWidth = windowWidth();
    _this.areaHeight = windowHeight();
    _this.bgcolor = 0xffffff;
    _this.delta = 1;
    _this.radius = 100;
    _this.theta = 0;
    _this.mouseX = 0;
    _this.mouseY = 0;
    /*
    	-------------------------------------------------------------
    	scene
    */

    _this.scene = new THREE.Scene;
    _this.scene.fog = new THREE.FogExp2(_this.bgcolor, 0.0015);
    /*
    	-------------------------------------------------------------
    	camra
    */

    _this.camera = new THREE.PerspectiveCamera(70, _this.areaWidth / _this.areaHeight, 1, 10000);
    _this.camera.position.set(0, 300, 500);
    _this.scene.add(_this.camera);
    /*
    	-------------------------------------------------------------
    	light
    */

    light = new THREE.DirectionalLight(0xffffff, 2);
    light.position.set(1, 1, 1).normalize();
    _this.scene.add(light);
    light = new THREE.DirectionalLight(0xffffff);
    light.position.set(-1, -1, -1).normalize();
    scene.add(light);
    /*
    	-------------------------------------------------------------
    	mesh
    */

    geometry = new THREE.CubeGeometry(20, 20, 20);
    l = 500;
    i = 0;
    while (i < l) {
      object = new THREE.Mesh(geometry, new THREE.MeshLambertMaterial({
        color: Math.random() * 0xffffff
      }));
      object.position.x = Math.random() * 800 - 400;
      object.position.y = Math.random() * 800 - 400;
      object.position.z = Math.random() * 800 - 400;
      object.rotation.x = (Math.random() * 360) * Math.PI / 180;
      object.rotation.y = (Math.random() * 360) * Math.PI / 180;
      object.rotation.z = (Math.random() * 360) * Math.PI / 180;
      object.scale.x = Math.random() * 2 + 1;
      object.scale.y = Math.random() * 2 + 1;
      object.scale.z = Math.random() * 2 + 1;
      _this.scene.add(object);
      i++;
    }
    /*
    	-------------------------------------------------------------
    	renderer
    */

    _this.renderer = new THREE.WebGLRenderer({
      antialias: false
    });
    _this.renderer.setClearColorHex(_this.bgcolor, 1);
    _this.renderer.autoClear = false;
    _this.renderer.setSize(_this.areaWidth, _this.areaHeight);
    _this.container.append(_this.renderer.domElement);
    initEffect();
    /*
    	-------------------------------------------------------------
    	stats
    */

    _this.stats = new Stats();
    st = stats.domElement;
    _this.container.append(st);
    $(st).css({
      "position": "absolute",
      "top": "0px"
    });
    /*
    	-------------------------------------------------------------
    	timer
    */

    _this.clock = new THREE.Clock();
    return update();
  };

  update = function() {
    var delta;
    requestAnimationFrame(update);
    delta = _this.clock.getDelta();
    /*
    	-------------------------------------------------------------
    	camera
    */

    theta += 0.2;
    _this.camera.position.x = radius * Math.sin(theta * Math.PI / 360);
    _this.camera.position.y = radius * Math.sin(theta * Math.PI / 360);
    _this.camera.position.z = radius * Math.cos(theta * Math.PI / 360);
    _this.camera.lookAt(_this.scene.position);
    /*
    	-------------------------------------------------------------
    	rendering
    */

    _this.renderer.clear();
    _this.composer.render(delta);
    /*
    	-------------------------------------------------------------
    	stats
    */

    return _this.stats.update();
  };

  initEffect = function() {
    var effectBloom, effectFilm, effectHSV, effectRGB, effectVignette, renderDepth, renderScene, renderSceneFocus, renderTarget, renderTargetParameters, renderToon1, screenPass, uniform1;
    renderTargetParameters = {
      format: THREE.RGBAFormat,
      stencilBuffer: false
    };
    renderTarget = new THREE.WebGLRenderTarget(this.areaWidth, this.areaHeight, renderTargetParameters);
    this.composer = new THREE.EffectComposer(this.renderer, renderTarget);
    renderScene = new THREE.RenderPass(this.scene, this.camera);
    screenPass = new THREE.ShaderPass(THREE.ShaderExtras["screen"]);
    /*
    	-------------------------------------------------------------
    	FocusBlurRender
    */

    renderSceneFocus = new FocusBlurPass(this.scene, this.camera);
    renderSceneFocus.setup(this.areaWidth, this.areaHeight, 1.1, 0.05, 1);
    /*
    	-------------------------------------------------------------
    	ToonRender
    	"toon2","hatching","dotted"
    */

    uniform1 = {
      uDirLightPos: new THREE.Vector3(1, 1, 1),
      uDirLightColor: new THREE.Color(0xffffff),
      uAmbientLightColor: new THREE.Color(0x000000)
    };
    renderToon1 = new ToonRenderPass(this.scene, this.camera, "toon2", uniform1);
    /*
    	-------------------------------------------------------------
    	DepthRender
    */

    renderDepth = new DepthRenderPass(this.scene, this.camera, 1000000, 400, this.areaWidth, this.areaHeight);
    /*
    	-------------------------------------------------------------
    	BloomEffect
    */

    effectBloom = new THREE.BloomPass(0.9);
    /*
    	-------------------------------------------------------------
    	FilmEffect
    */

    effectFilm = new THREE.FilmPass(0.9, 0.5, 1024, true);
    /*
    	-------------------------------------------------------------
    	RGBshift
    */

    effectRGB = new RGBshiftPass();
    /*
    	-------------------------------------------------------------
    	HSVgradation
    */

    effectHSV = new HSVGradationPass(0.5);
    /*
    	-------------------------------------------------------------
    	tunnelEffect
    */

    effectVignette = new THREE.ShaderPass(THREE.ShaderExtras["vignette"]);
    effectVignette.uniforms["offset"].value = 0.5;
    effectVignette.uniforms["darkness"].value = 2.0;
    /*
    	-------------------------------------------------------------
    	compose
    */

    this.composer.addPass(renderDepth);
    this.composer.addPass(effectBloom);
    this.composer.addPass(effectVignette);
    this.composer.addPass(effectFilm);
    this.composer.addPass(effectHSV);
    this.composer.addPass(effectRGB);
    this.composer.addPass(effectVignette);
    this.composer.addPass(screenPass);
    return screenPass.renderToScreen = true;
  };

  windowWidth = function() {
    var size;
    size = 0;
    if (document.documentElement.clientWidth) {
      size = document.documentElement.clientWidth;
    } else {
      if (document.body.clientWidth) {
        size = document.body.clientWidth;
      } else {
        if (window.innerWidth) {
          size = window.innerWidth;
        }
      }
    }
    return size;
  };

  windowHeight = function() {
    var size;
    size = 0;
    if (document.documentElement.clientHeight) {
      size = document.documentElement.clientHeight;
    } else {
      if (document.body.clientHeight) {
        size = document.body.clientHeight;
      } else {
        if (window.innerHeight) {
          size = window.innerHeight;
        }
      }
    }
    return size;
  };

}).call(this);