$ =>
	if Detector.webgl
		init()

init = =>
	@container = $("body")
	@areaWidth = windowWidth()
	@areaHeight = windowHeight()
	@bgcolor = 0xffffff
	@delta = 1
	@radius = 100
	@theta = 0
	@mouseX = 0
	@mouseY = 0

	###
	-------------------------------------------------------------
	scene
	###
	@scene = new THREE.Scene
	@scene.fog = new THREE.FogExp2( @bgcolor, 0.0015 );

	###
	-------------------------------------------------------------
	camra
	###
	@camera = new THREE.PerspectiveCamera( 70, @areaWidth / @areaHeight, 1, 10000 );
	@camera.position.set( 0, 300, 500 );
	@scene.add @camera

	###
	-------------------------------------------------------------
	light
	###
	light = new THREE.DirectionalLight( 0xffffff, 2 );
	light.position.set( 1, 1, 1 ).normalize();
	@scene.add( light );

	light = new THREE.DirectionalLight( 0xffffff );
	light.position.set( -1, -1, -1 ).normalize();
	scene.add( light );

	###
	-------------------------------------------------------------
	mesh
	###
	geometry = new THREE.CubeGeometry( 20, 20, 20 );
	l = 500
	i = 0
	while i < l
		object = new THREE.Mesh( geometry, new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ) );
		object.position.x = Math.random() * 800 - 400;
		object.position.y = Math.random() * 800 - 400;
		object.position.z = Math.random() * 800 - 400;

		object.rotation.x = ( Math.random() * 360 ) * Math.PI / 180;
		object.rotation.y = ( Math.random() * 360 ) * Math.PI / 180;
		object.rotation.z = ( Math.random() * 360 ) * Math.PI / 180;

		object.scale.x = Math.random() * 2 + 1;
		object.scale.y = Math.random() * 2 + 1;
		object.scale.z = Math.random() * 2 + 1;

		@scene.add( object );
		i++

	###
	-------------------------------------------------------------
	renderer
	###
	@renderer = new THREE.WebGLRenderer {antialias: false}
	@renderer.setClearColorHex @bgcolor, 1
	@renderer.autoClear = false;
	@renderer.setSize @areaWidth, @areaHeight
	@container.append @renderer.domElement 

	initEffect()

	###
	-------------------------------------------------------------
	stats
	###
	@stats = new Stats()
	st = stats.domElement
	@container.append st
	$(st).css({"position":"absolute", "top":"0px"})

	###
	-------------------------------------------------------------
	timer
	###
	@clock = new THREE.Clock();
	update()
		
update = =>
	requestAnimationFrame update

	delta = @clock.getDelta();

	###
	-------------------------------------------------------------
	camera
	###
	theta += 0.2;
	@camera.position.x = radius * Math.sin( theta * Math.PI / 360 );
	@camera.position.y = radius * Math.sin( theta * Math.PI / 360 );
	@camera.position.z = radius * Math.cos( theta * Math.PI / 360 );
	@camera.lookAt( @scene.position );

	###
	-------------------------------------------------------------
	rendering
	###
	@renderer.clear();
	@composer.render delta

	###
	-------------------------------------------------------------
	stats
	###
	@stats.update()

#------------------------------------------------------------
initEffect = ->
	renderTargetParameters = { format: THREE.RGBAFormat, stencilBuffer: false }
	renderTarget = new THREE.WebGLRenderTarget @areaWidth, @areaHeight, renderTargetParameters
	@composer = new THREE.EffectComposer @renderer, renderTarget
	renderScene = new THREE.RenderPass @scene, @camera
	screenPass = new THREE.ShaderPass THREE.ShaderExtras[ "screen" ]

	###
	-------------------------------------------------------------
	FocusBlurRender
	###
	renderSceneFocus = new FocusBlurPass @scene, @camera
	renderSceneFocus.setup @areaWidth, @areaHeight, 1.1, 0.05, 1 

	###
	-------------------------------------------------------------
	ToonRender
	"toon2","hatching","dotted"
	###
	uniform1 = {
		uDirLightPos: new THREE.Vector3(1, 1, 1)
		uDirLightColor: new THREE.Color( 0xffffff )
		uAmbientLightColor: new THREE.Color( 0x000000 )
	}
	renderToon1 = new ToonRenderPass @scene, @camera, "toon2", uniform1

	###
	-------------------------------------------------------------
	DepthRender
	###
	renderDepth = new DepthRenderPass @scene, @camera, 1000000, 400, @areaWidth, @areaHeight

	###
	-------------------------------------------------------------
	BloomEffect
	###
	effectBloom = new THREE.BloomPass 0.9

	###
	-------------------------------------------------------------
	FilmEffect
	###
	effectFilm = new THREE.FilmPass 0.9, 0.5, 1024, true

	###
	-------------------------------------------------------------
	RGBshift
	###
	effectRGB = new RGBshiftPass()

	###
	-------------------------------------------------------------
	HSVgradation
	###
	effectHSV = new HSVGradationPass(0.5)

	###
	-------------------------------------------------------------
	tunnelEffect
	###
	effectVignette = new THREE.ShaderPass THREE.ShaderExtras[ "vignette" ]
	effectVignette.uniforms[ "offset" ].value = 0.5
	effectVignette.uniforms[ "darkness" ].value = 2.0
	
	###
	-------------------------------------------------------------
	compose
	###
	#@composer.addPass renderScene
	#@composer.addPass renderSceneFocus
	#@composer.addPass renderToon1
	@composer.addPass renderDepth

	@composer.addPass effectBloom
	@composer.addPass effectVignette
	@composer.addPass effectFilm
	@composer.addPass effectHSV
	@composer.addPass effectRGB
	@composer.addPass effectVignette
	@composer.addPass screenPass
	#effectVignette.renderToScreen = true
	screenPass.renderToScreen = true;


#------------------------------------------------------------
windowWidth = ->
	size = 0
	
	if document.documentElement.clientWidth
		size = document.documentElement.clientWidth
	else
		if document.body.clientWidth
			size = document.body.clientWidth
		else 
			if window.innerWidth
				size = window.innerWidth
	size

windowHeight = ->
	size = 0
  
	if document.documentElement.clientHeight
		size = document.documentElement.clientHeight
	else
		if document.body.clientHeight
			size = document.body.clientHeight
		else
			if window.innerHeight
				size = window.innerHeight     
	size