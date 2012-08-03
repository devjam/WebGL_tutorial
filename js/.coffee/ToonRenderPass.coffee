class ToonRenderPass
	@TOON1 = "toon1"
	@TOON2 = "toon2"
	@HATCHING = "hatching"
	@DOTTED = "dotted"

	constructor: ( scene, camera, type, uniforms, clearColor, clearAlpha )->
		@scene = scene
		@camera = camera
		@clearColor = clearColor
		@clearAlpha = clearAlpha

		@enabled = true
		@clear = true
		@needsSwap = false

		if type is not ToonRenderPass.TOON1 or type is not ToonRenderPass.TOON2 or type is not ToonRenderPass.HATCHING or type is not ToonRenderPass.DOTTED
			return null

		shader = THREE.ShaderToon[ type ]
		@uniforms = THREE.UniformsUtils.clone shader.uniforms
		for i of uniforms
			if @uniforms[i]?
				@uniforms[i].value = uniforms[i]
		@material = new THREE.ShaderMaterial(
			uniforms: @uniforms
			vertexShader: shader.vertexShader
			fragmentShader: shader.fragmentShader
		)

	render: ( renderer, writeBuffer, readBuffer, delta )->
		if @material?
			@scene.overrideMaterial = @material
		if @clearColor
			@oldClearColor.copy renderer.getClearColor()
			@oldClearAlpha = renderer.getClearAlpha()
			renderer.setClearColor @clearColor, @clearAlpha
		renderer.render @scene, @camera, readBuffer, @clear
		if @clearColor
			renderer.setClearColor @oldClearColor, @oldClearAlpha
		@scene.overrideMaterial = null;

@ToonRenderPass = ToonRenderPass