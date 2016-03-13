//
//  Mat3x3.h
//  Assignment4
//
//  Created by dc10 on 14/10/24.
//
//

#ifndef CGLab3_Mat3x3_h
#define CGLab3_Mat3x3_h
#include <math.h>
#include <GLUT/GLUT.h>
#include "Vec3.h"

#include <math.h>
#include <limits>
#include <algorithm>

class Mat3x3
{
public:
    typedef float MatType;
    typedef vec3  VecType;
    static const int dim = 3;
    static const int len = 9;
    
public:
    void setRotX(float radians);
    void setRotY(float radians);
    VecType operator*(const VecType& v) const;
    void set(float m0, float m1, float m2,
             float m3, float m4, float m5,
             float m6, float m7, float m8);
protected:
    float numVerts[9];
};

void Mat3x3::setRotX(float radians)
{
    float s = sinf(radians);
    float c = cosf(radians);
    
    set(float(1), float(0), float(0),
        float(0), c,    s,
        float(0), -s,    c);
}

void Mat3x3::setRotY(float radians)
{
    float s = sinf(radians);
    float c = cosf(radians);
    
    set(c,    float(0),  s,
        float(0),float(1),float(0),
        -s,   float(0),  c);
}


Mat3x3::VecType Mat3x3::operator*(const VecType&rhs) const
{
    vec3    v(numVerts[0]*rhs.x + numVerts[1]*rhs.y + numVerts[2]*rhs.z,
              numVerts[3]*rhs.x + numVerts[4]*rhs.y + numVerts[5]*rhs.z,
              numVerts[6]*rhs.x + numVerts[7]*rhs.y + numVerts[8]*rhs.z);
    return v;
}


void Mat3x3::set(float m0, float m1, float m2,
                 float m3, float m4, float m5,
                 float m6, float m7, float m8)
{
    numVerts[0] = m0;
    numVerts[1] = m1;
    numVerts[2] = m2;
    numVerts[3] = m3;
    numVerts[4] = m4;
    numVerts[5] = m5;
    numVerts[6] = m6;
    numVerts[7] = m7;
    numVerts[8] = m8;
}


#endif
