class HSVGradationPass
	@shader = 
		uniforms: 
			tDiffuse:	{ type: "t", value: 0, texture: null }
			time:			{ type: "f", value: 0.0 }
			opacity:	{	type: "f", value: 0.0 }

		vertexShader: '''
			varying vec2 vUv;
			void main() {
				vUv = vec2( uv.x, 1.0 - uv.y );
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}
		'''

		fragmentShader: '''
			uniform sampler2D tDiffuse;
			uniform float time;
			uniform float opacity;

			varying vec2 vUv;

			void main() {
				vec3 hsv = vec3((vUv.x + time * 0.1 + vUv.y * 0.25) * 120.0, 1.0, 1.0);
				vec3 rgb = texture2D(tDiffuse, vUv).rgb;

				vec3 col;
				float hue = mod(hsv.r, 360.0);
				float s = hsv.g * 1.0;
				float v = hsv.b * 1.0;
				if(s < 0.0) { s = 0.0; }
				if(s > 1.0) { s = 1.0; }
				if(v < 0.0) { v = 0.0; }
				if(v > 1.0) { v = 1.0; }
				if(s > 0.0) {
					int h = int(floor(hue / 60.0));
					float f = hue / 60.0 - float(h);
					float p = v * (1.0 - s);
					float q = v * (1.0 - f * s);
					float r = v * (1.0 - (1.0 - f) * s);

					if(h == 0) col = vec3(v, r, p);
					else if(h == 1) col = vec3(q, v, p);
					else if(h == 2) col = vec3(p, v, r);
					else if(h == 3) col = vec3(p, q, v);
					else if(h == 4) col = vec3(r, p, v);
					else col = vec3(v, p, q);
				}else{
					col = vec3(v);
				}

				rgb += col * opacity;
				gl_FragColor.rgb = rgb;
				gl_FragColor.a = 1.0;
			}
		'''

	constructor: (opacity = 0.5)->
		#@time = 0
		@opacity = opacity
		shader = HSVGradationPass.shader
		@uniforms = THREE.UniformsUtils.clone shader.uniforms
		@uniforms[ "opacity" ].value = @opacity
		@material = new THREE.ShaderMaterial(
			uniforms: @uniforms
			vertexShader: shader.vertexShader
			fragmentShader: shader.fragmentShader
		)
		@enabled = true
		@renderToScreen = false
		@needsSwap = true

	render: ( renderer, writeBuffer, readBuffer, delta )->
		#@time += delta
		@uniforms[ "tDiffuse" ].texture = readBuffer
		@uniforms[ "opacity" ].value = @opacity
		@uniforms[ "time" ].value += delta
		THREE.EffectComposer.quad.material = @material
		if @renderToScreen
			renderer.render THREE.EffectComposer.scene, THREE.EffectComposer.camera
		else
			renderer.render THREE.EffectComposer.scene, THREE.EffectComposer.camera, writeBuffer, false

@HSVGradationPass = HSVGradationPass
