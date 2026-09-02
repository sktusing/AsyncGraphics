//
//  QuaternionUniform.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-09-02.
//

import simd

struct QuaternionUniform: Uniforms {

    let x: Float
    let y: Float
    let z: Float
    let w: Float
}

extension QuaternionUniform {

    static let identity = QuaternionUniform(
        x: 0.0,
        y: 0.0,
        z: 0.0,
        w: 1.0
    )
}

extension simd_quatf {

    var uniform: QuaternionUniform {
        QuaternionUniform(
            x: imag.x,
            y: imag.y,
            z: imag.z,
            w: real
        )
    }
}
