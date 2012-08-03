class FocusBlurPass
	constructor: ( scene, camera, overrideMaterial, clearColor, clearAlpha = 1 )->
		@scene = scene
		@camera = camera
		@overrideMaterial = overrideMaterial
		@clearColor = clearColor
		@clearAlpha = clearAlpha

		@enabled = true
		@clear = true
		@needsSwap = false
		@material_depth = new THREE.MeshDepthMaterial()

		@focus = null
		@aperture = 0.05
		@maxblur = 2

	setup: (width, height, focus = null, aperture = null, maxblur = null) ->
		if focus?
			@focus = focus
		if aperture?
			@aperture = aperture
		if maxblur?
			@maxblur = maxblur

		if width? and height?
			pars = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat }
			@TextureDepth = new THREE.WebGLRenderTarget width, height, pars
			@TextureColor = new THREE.WebGLRenderTarget width, height, pars

			shader = THREE.ShaderExtras[ "bokeh" ]
			@uniforms = THREE.UniformsUtils.clone shader.uniforms
			@uniforms[ "tColor" ].texture = @TextureColor
			@uniforms[ "tDepth" ].texture = @TextureDepth
			@uniforms[ "focus" ].value = @focus
			@uniforms[ "aperture" ].value = @aperture;
			@uniforms[ "maxblur" ].value = @maxblur;
			@uniforms[ "aspect" ].value = width / height

			@material = new THREE.ShaderMaterial(
				uniforms: @uniforms
				vertexShader: shader.vertexShader
				fragmentShader: shader.fragmentShader
			)

	render: ( renderer, writeBuffer, readBuffer, delta )->
		@scene.overrideMaterial = @overrideMaterial
		if @clearColor
			@oldClearColor.copy renderer.getClearColor()
			@oldClearAlpha = renderer.getClearAlpha()
			renderer.setClearColor @clearColor, @clearAlpha

		if @focus?
			@scene.overrideMaterial = null;
			renderer.render( @scene, @camera, @TextureColor, true );
			@scene.overrideMaterial = @material_depth;
			renderer.render( @scene, @camera, @TextureDepth, true );
			@uniforms[ "focus" ].value = @focus
			@uniforms[ "aperture" ].value = @aperture;
			@uniforms[ "maxblur" ].value = @maxblur;
			THREE.EffectComposer.quad.material = @material
			renderer.render THREE.EffectComposer.scene, THREE.EffectComposer.camera, readBuffer, false

		else
			renderer.render @scene, @camera, readBuffer, @clear

		if @clearColor
			renderer.setClearColor @oldClearColor, @oldClearAlpha
		@scene.overrideMaterial = null;


@FocusBlurPass = FocusBlurPass