class RGBshiftPass
	@shader = 
		uniforms: 
			tDiffuse:	{ type: "t", value: 0, texture: null }
			time:			{ type: "f", value: 0.0 }
			width:		{ type: "f", value: 0.0 }
			height:		{ type: "f", value: 0.0 }
			offsetR:	{ type: "v2", value: new THREE.Vector2(0.0, 0.0) }
			offsetG:	{ type: "v2", value: new THREE.Vector2(0.0, 0.0) }
			offsetB:	{ type: "v2", value: new THREE.Vector2(0.0, 0.0) }

		vertexShader: '''
			varying vec2 vUv;
			void main() {
				vUv = vec2( uv.x, 1.0 - uv.y );
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}
		'''

		fragmentShader: '''
			uniform sampler2D tDiffuse;
			uniform float width;
			uniform float height;
			uniform vec2 offsetR;
			uniform vec2 offsetG;
			uniform vec2 offsetB;

			varying vec2 vUv;
			void main() {
				vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
				vec2 offset_r = vec2(offsetR.x / width, offsetR.y / height);
				vec2 offset_g = vec2(offsetG.x / width, offsetG.y / height);
				vec2 offset_b = vec2(offsetB.x / width, offsetB.y / height);
				offset_r += vUv;
				offset_g += vUv;
				offset_b += vUv;
				color.r = texture2D(tDiffuse, offset_r).r;
				color.g = texture2D(tDiffuse, offset_g).g;
				color.b = texture2D(tDiffuse, offset_b).b;
				gl_FragColor = color;
			}
		'''

	constructor: ->
		shader = RGBshiftPass.shader
		@uniforms = THREE.UniformsUtils.clone shader.uniforms
		@uniforms["offsetR"].value = new THREE.Vector2(0.0, 1.5)
		@uniforms["offsetG"].value = new THREE.Vector2(1.0, 0.0)
		@uniforms["offsetB"].value = new THREE.Vector2(0.0, -1.5)
		@material = new THREE.ShaderMaterial(
			uniforms: @uniforms
			vertexShader: shader.vertexShader
			fragmentShader: shader.fragmentShader
		)
		@enabled = true
		@renderToScreen = false
		@needsSwap = true

	render: ( renderer, writeBuffer, readBuffer, delta )->
		@uniforms[ "tDiffuse" ].texture = readBuffer
		@uniforms[ "width" ].value = readBuffer.width * 1.0;
		@uniforms[ "height" ].value = readBuffer.height * 1.0;
		@uniforms[ "time" ].value += delta
		THREE.EffectComposer.quad.material = @material
		if @renderToScreen
			renderer.render THREE.EffectComposer.scene, THREE.EffectComposer.camera
		else
			renderer.render THREE.EffectComposer.scene, THREE.EffectComposer.camera, writeBuffer, false

@RGBshiftPass = RGBshiftPass