class DepthRenderPass
	@shader = 
		uniforms:
			tDiffuse:	{ type: "t", value: 0, texture: null }
			steps: { type: "f", value: 1.0}

		vertexShader: '''
			varying vec2 vUv;
			void main() {
				vUv = vec2( uv.x, 1.0 - uv.y );
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}
		'''

		fragmentShader: '''
			uniform sampler2D tDiffuse;
			uniform float steps;

			varying vec2 vUv;
			void main() {
				float c = texture2D(tDiffuse, vUv).r * steps;
				float v = mod(c, 2.0);
				if (v < 1.0) { v = 0.0; } else { v = 1.0; }
				gl_FragColor = vec4(v, v, v, 1.0);
			}
		'''

	constructor: ( scene, camera, steps, far, width, height, clearColor, clearAlpha = 1 )->
		@scene = scene
		@camera = camera
		@steps = steps
		@far = far
		@original_far = camera.far
		@clearColor = clearColor
		@clearAlpha = clearAlpha

		@enabled = true
		@clear = true
		@needsSwap = false

		@material_depth = new THREE.MeshDepthMaterial({ near: 1, far: @original_far })
		pars = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat }
		@TextureDepth = new THREE.WebGLRenderTarget width, height, pars

		shader = DepthRenderPass.shader
		@uniforms = THREE.UniformsUtils.clone shader.uniforms
		@uniforms[ "tDiffuse" ].texture = @TextureDepth
		@material = new THREE.ShaderMaterial(
			uniforms: @uniforms
			vertexShader: shader.vertexShader
			fragmentShader: shader.fragmentShader
		)

	render: ( renderer, writeBuffer, readBuffer, delta )->
		@scene.overrideMaterial = @material_depth
		#@scene.overrideMaterial = new THREE.MeshDepthMaterial( { near: 1, far: @original_far } );
		@camera.far = @far
		if @clearColor
			@oldClearColor.copy renderer.getClearColor()
			@oldClearAlpha = renderer.getClearAlpha()
			renderer.setClearColor @clearColor, @clearAlpha
		renderer.render( @scene, @camera, @TextureDepth, true );
		@uniforms[ "steps" ].value = @steps
		THREE.EffectComposer.quad.material = @material
		renderer.render THREE.EffectComposer.scene, THREE.EffectComposer.camera, readBuffer, false
		if @clearColor
			renderer.setClearColor @oldClearColor, @oldClearAlpha
		@scene.overrideMaterial = null;
		@camera.far = @original_far

@DepthRenderPass = DepthRenderPass