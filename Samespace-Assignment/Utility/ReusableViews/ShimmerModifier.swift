//
//  ShimmerModifier.swift
//  Samespace-Assignment
//
//  Created by Harsh Yadav on 14/04/24.
//

import SwiftUI

struct ShimmerConfig {
	var tint: Color
	var highLight: Color
	var blur: CGFloat = 0
	var highlightOpacity: CGFloat = 1
	var speed: CGFloat = 2
}

extension View {
	
	@ViewBuilder
	func shimer(_ config: ShimmerConfig) -> some View {
		self
			.modifier(ShimmerModifier(config: config))
	}
}

struct ShimmerModifier: ViewModifier {
	
	var config: ShimmerConfig
	@State private var moveTo: CGFloat = -0.7
	
	func body(content: Content) -> some View {
		content
			.hidden()
			.overlay {
				Rectangle()
					.fill(config.tint)
					.mask {
						content
					}
					.overlay {
						GeometryReader { proxy in
							
							let size = proxy.size
							let extraOffset = size.height/2.5
							
							Rectangle()
								.fill(config.highLight)
								.mask {
									Rectangle()
										.fill (
											.linearGradient(
												colors: [
												.white.opacity(0),
												config.highLight.opacity(config.highlightOpacity),
												.white.opacity(0)
												],
												startPoint: .top,
												endPoint: .bottom)
										)
										.blur(radius: config.blur)
										.rotationEffect(.init(degrees: -70))
										.offset(x: moveTo > 0 ? extraOffset : -extraOffset)
										.offset(x: size.width*moveTo)
							
									}
						}
						.mask {
							content
						}
					}
					.onAppear {
						DispatchQueue.main.async {
							moveTo = 0.7
						}
					}
					.animation(.linear(duration: config.speed).repeatForever(autoreverses: false), value: moveTo)
			}
	}
}
