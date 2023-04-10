//
//  MapConverSion.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/10.
//

import Foundation

struct lamcParameter {
    var Re: Double /* 사용할지구반경[ km ] */
    var grid: Double /* 격자간격[ km ] */
    var slat1: Double /* 표준위도[degree] */
    var slat2: Double /* 표준위도[degree] */
    var olon: Double /* 기준점의경도[degree] */
    var olat: Double /* 기준점의위도[degree] */
    var xo: Double /* 기준점의X좌표[격자거리] */
    var yo: Double /* 기준점의Y좌표[격자거리] */
    var first: Int /* 시작여부(0 = 시작) */
}

class MapConversion {
    
    // lattitude and longitude to lattice (x,y)
    func lamcproj(_ longitude: Double, _ lattitude: Double)->(Double, Double){
        
        let lamcPars = lamcParameter(Re: 6371.00877, grid: 5.0, slat1: 30.0, slat2: 60.0, olon: 126.0, olat: 38.0, xo: 210/5.0, yo: 675/5.0, first: 0)
        
        let PI = asin(1.0)*2.0
        let DEGRAD = PI/180.0
        // let RADDEG = 180.0/PI
        
        let re = lamcPars.Re/lamcPars.grid
        let slat1 = lamcPars.slat1 * DEGRAD
        let slat2 = lamcPars.slat2 * DEGRAD
        let olon = lamcPars.olon * DEGRAD
        let olat = lamcPars.olat * DEGRAD

        var sn = tan(PI*0.25 + slat2*0.5)/tan(PI*0.25 + slat1*0.5)
        sn = log(cos(slat1)/cos(slat2))/log(sn)
        var sf = tan(PI*0.25 + slat1*0.5)
        sf = pow(sf,sn)*cos(slat1)/sn
        var ro = tan(PI*0.25 + olat*0.5)
        ro = re*sf/pow(ro,sn)
        
        var ra = tan(PI*0.25+lattitude*DEGRAD*0.5)
        ra = re*sf/pow(ra,sn)
        var theta = longitude*DEGRAD - olon
        if (theta > PI) { theta -= 2.0*PI }
        if (theta < -PI) { theta += 2.0*PI }
        theta *= sn
        let x = Double(ra*sin(theta)) + lamcPars.xo
        let y = Double(ro - ra*cos(theta)) + lamcPars.yo

        return (x, y)
    }
}
