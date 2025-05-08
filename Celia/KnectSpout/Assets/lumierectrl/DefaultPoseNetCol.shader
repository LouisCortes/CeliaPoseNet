Shader "Unlit/DefaultPoseNetCol"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
		_posTest("_posTest",Vector) = (0,0,0,0)
		_t1("_t1",Float) = 0
		_t2("_t2",Float) = 0
		_t3("_t3",Float) = 0
		_ttscore("_ttscore",Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _posTest;
			sampler2D _PosTex;
			float3 _pos[17];
			float3 _pos2[17];
			float3 _pos3[17];
			float _score[17];
			float _score2[17];
			float _score3[17];

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
			            float3 InvLerp(float3 A, float3 B, float3 t){return (t - A) / (B - A);}
            float3 co(float3 InColor ,float3 s, float3 m, float3 h){
                float3 OffShadows  = InColor + s;
                float3 OffMidtones = InColor + m;
                float3 OffHilights = InColor + h;
                return lerp(
                    lerp(OffShadows,  OffMidtones, InvLerp(float3(0.0, 0.0, 0.0), float3(0.5, 0.5, 0.5), InColor)),
                    lerp(OffMidtones, OffHilights, InvLerp(float3(0.5, 0.5, 0.5), float3(1.0, 1.0, 1.0), InColor)),
                    step( float3(0.5, 0.5, 0.5), InColor));
            }
               float rd(float t){return frac(sin(dot(floor(t),45.236))*7845.236+_Time.y*0.5);}
    float rd2(float t){return frac(sin(dot(floor(t),45.236))*7845.236);}
    float4 rd4(float t){float ft = floor(t); return frac(sin(float4(dot(ft,45.236),dot(ft,98.147),dot(ft,23.15),dot(ft,67.19)))*7845.236);}
float no(float t){return lerp(rd(t),rd(t+1.),smoothstep(0.,1.,frac(t)));}
float rl(float t){return frac(sin(dot(floor(t),45.236))*7845.236);}
float nl(float t){return lerp(rl(t),rl(t+1.),smoothstep(0.,1.,frac(t)));}
float li(float2 uv,float2 a, float2 b ){
float2 ua  = uv-a; float2 ba = b-a; float h  = clamp(dot(ua,ba)/dot(ba,ba),0.,1.);
return length(ua-ba*h);
}
float sdl(float2 p, float2 lineA, float2 lineB)
{
    float2 lineDir = normalize(lineB - lineA);
    float2 pointDir = p - lineA;
    float distance = abs(dot(float2(-lineDir.y, lineDir.x), pointDir));
    return distance;
}
float smin( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h);
}
float SmoothDamp(float current, float target, inout float currentVelocity, float smoothTime, float deltaTime, float maxSpeed)
{
    smoothTime = max(0.0001, smoothTime);
    float omega = 2.0 / smoothTime;
    float x = omega * deltaTime;
    float exp = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);
    float change = current - target;
    float originalTo = target;
    float maxChange = maxSpeed * smoothTime;
    change = clamp(change, -maxChange, maxChange);
    target = current - change;
    float temp = (currentVelocity + omega * change) * deltaTime;
    currentVelocity = (currentVelocity - omega * temp) * exp;
    float output = target + (change + temp) * exp;

    return output;
}
float4 level;
float lev(float color, float4 l){
    color = (color - l.x) / (l.y - l.x) * (l.w - l.z) + l.z;
    return color;}
    float dot2( in float2 v ) { return dot(v,v); }
float cro( in float2 a, in float2 b ) { return a.x*b.y - a.y*b.x; }
float bez( float2 pos, float2 A,  float2 B,  float2 C ){
    float2 a = B - A;
    float2 b = A - 2.0*B + C;
    float2 c = a * 2.0;
    float2 d = A - pos;
    float kk = 1.0/dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);
    float res = 0.0;
    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx-3.0*ky) + kz;
    float h = q*q + 4.0*p3;
    if( h >= 0.0){
        h = sqrt(h);
        float2 x = (float2(h,-h)-q)/2.0;
        float t3 = 1./3.;
        float2 uv = sign(x)*pow(abs(x), float2(t3,t3));
        float t = clamp( uv.x+uv.y-kx, 0.0, 1.0 );
        res = dot2(d + (c + b*t)*t);}
    else  {
        float z = sqrt(-p);
        float v = acos( q/(p*z*2.0) ) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        float3  t = clamp(float3(m+m,-n-m,n-m)*z-kx,0.0,1.0);
        res = min( dot2(d+(c+b*t.x)*t.x),
                   dot2(d+(c+b*t.y)*t.y) );}
      return sqrt( res );}

      float spo8(float2 v[8], float2 p)
      {
          float d = dot(p - v[0], p - v[0]);
          float s = 1.0;
          for (int i = 0, j = 7; i < 8; j = i, i++)
          {
              float2 e = v[j] - v[i];
              float2 w = p - v[i];
              float2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
              d = min(d, dot(b, b));
              bool3 c = bool3(p.y >= v[i].y, p.y < v[j].y, e.x * w.y > e.y * w.x);
              if (all(c) || all(!c))
                  s *= -1.0;
          }
          return s * sqrt(d);
      }
      float spo5(float2 v[5], float2 p)
      {
          float d = dot(p - v[0], p - v[0]);
          float s = 1.0;
          for (int i = 0, j = 4; i < 5; j = i, i++)
          {
              float2 e = v[j] - v[i];
              float2 w = p - v[i];
              float2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
              d = min(d, dot(b, b));
              bool3 c = bool3(p.y >= v[i].y, p.y < v[j].y, e.x * w.y > e.y * w.x);
              if (all(c) || all(!c))
                  s *= -1.0;
          }
          return s * sqrt(d);
      }
      float spo3(float2 v[3], float2 p)
      {
          float d = dot(p - v[0], p - v[0]);
          float s = 1.0;
          for (int i = 0, j = 2; i < 3; j = i, i++)
          {
              float2 e = v[j] - v[i];
              float2 w = p - v[i];
              float2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
              d = min(d, dot(b, b));
              bool3 c = bool3(p.y >= v[i].y, p.y < v[j].y, e.x * w.y > e.y * w.x);
              if (all(c) || all(!c))
                  s *= -1.0;
          }
          return s * sqrt(d);
      }
      float spo4(float2 v[4], float2 p)
      {
          float d = dot(p - v[0], p - v[0]);
          float s = 1.0;
          for (int i = 0, j = 3; i < 4; j = i, i++)
          {
              float2 e = v[j] - v[i];
              float2 w = p - v[i];
              float2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
              d = min(d, dot(b, b));
              bool3 c = bool3(p.y >= v[i].y, p.y < v[j].y, e.x * w.y > e.y * w.x);
              if (all(c) || all(!c))
                  s *= -1.0;
          }
          return s * sqrt(d);
      }
      float spo13(float2 v[13], float2 p)
      {
          float d = dot(p - v[0], p - v[0]);
          float s = 1.0;
          for (int i = 0, j = 12; i < 13; j = i, i++)
          {
              float2 e = v[j] - v[i];
              float2 w = p - v[i];
              float2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
              d = min(d, dot(b, b));
              bool3 c = bool3(p.y >= v[i].y, p.y < v[j].y, e.x * w.y > e.y * w.x);
              if (all(c) || all(!c))
                  s *= -1.0;
          }
          return s * sqrt(d);
      }
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
			float2 re = float2(16. / 9.,1.);
            float2 fac = re;
			float d1 = 0.;
            float ligne =0.8;
            float zp = 0.001;
            float2 uli = i.uv;
            float2 ulif = uli*re;
            float trp = 12.;
       
        float pof = 0.;float pof2 = 0.;float pof3 = 0.;

        if(max(_pos[0].z,max(max(_pos[11].z,_pos[10].z),max(_pos[5].z,_pos[6].z)))>0.4){
        float4 rpo  = rd4(_Time.y*trp);
        float4 rpo2 = rd4(_Time.y*trp+78.45);
        float4 rpo3 = rd4(_Time.y*trp+425.36);
          float2 p0 = _pos[0].xy *re;
            float2 p1 = _pos[9].xy *re;
            float2 p2 = _pos[10].xy *re;
            float2 p3 = _pos[13].xy *re;
            float2 p4 = _pos[14].xy *re;
            float2 p0s = _pos[0].xy *re;
            float2 p1s = _pos[5].xy *re;
            float2 p4s = _pos[6].xy *re;
            float2 p2s = _pos[7].xy *re;
            float2 p5s = _pos[8].xy *re;
            float2 p3s = _pos[9].xy *re;
            float2 p6s = _pos[10].xy *re;
            float2 p7s = _pos[11].xy *re;
            float2 p8s = _pos[12].xy *re;
            float2 p9s = _pos[13].xy *re;
            float2 p11s = _pos[14].xy *re;
            float2 p10s = _pos[15].xy *re;
            float2 p12s = _pos[16].xy *re;
      float2 pr0s[8];pr0s[0] = p1s;pr0s[1] = p2s;pr0s[2] = p3s;pr0s[3] = p7s;pr0s[4] = p6s;pr0s[5] = p5s;pr0s[6] = p4s;pr0s[7] = p0s;
      float2 pr2s[5];pr2s[0] = p0s;pr2s[1] = p3s;pr2s[2] = p10s;pr2s[3] = p12s;pr2s[4] = p6s;
      float2 pr3s[13];pr3s[0] =p0s;pr3s[1] = p1s;pr3s[2] = p2s;pr3s[3] = p3s;pr3s[4] = p7s;pr3s[5] = p9s;pr3s[6] = p10s;pr3s[7] = p12s;
      pr3s[8] =p11s;pr3s[9] = p8s;pr3s[10] = p6s;pr3s[11] = p5s;pr3s[12] = p4s;
      float2 pr4s[3];pr4s[0] = p1s;pr4s[1] = p2s;pr4s[2] = p3s;
      float2 pr5s[3];pr5s[0] = p4s;pr5s[1] = p5s;pr5s[2] = p6s;
      float2 pr6s[3];pr6s[0] = p7s;pr6s[1] = p8s;pr6s[2] = p10s;
      float2 pr7s[3];pr7s[0] = p8s;pr7s[1] = p11s;pr7s[2] = p12s;
      float2 pr8s[4];pr8s[0] = p1s;pr8s[1] = p7s;pr8s[2] = p8s;pr8s[3] = p4s;
      float2 pr9s[4];pr9s[0] = p1s;pr9s[1] = p10s;pr9s[2] = p12s;pr9s[3] = p4s;

      float ps1 = 0.;float ps2 = 0;float ps3 = 0.;float ps4 =0.;float ps5 = 0.;float ps6 = 0.;float ps7= 0.;float ps8 = 0.; float ps9 = 0.;
             if(rpo.x>ligne){ps1 = smoothstep(zp,0.,length(spo8(pr0s,ulif)));}
             if(rpo.y>ligne){ps2 = smoothstep(zp,0.,length(spo5(pr2s,ulif)));}
             if(rpo.z>ligne){ps3 = smoothstep(zp,0.,length(spo13(pr3s,ulif)));}
             if(rpo.w>ligne){ps4 = smoothstep(zp,0.,length(spo3(pr4s,ulif)));}
             if(rpo2.x>ligne){ps5 = smoothstep(zp,0.,length(spo3(pr5s,ulif)));}
             if(rpo2.y>ligne){ps6 = smoothstep(zp,0.,length(spo3(pr6s,ulif)));}
             if(rpo2.z>ligne){ps7 = smoothstep(zp,0.,length(spo3(pr7s,ulif)));}
             if(rpo2.w>ligne){ps8 = smoothstep(zp,0.,length(spo4(pr8s,ulif)));}
             if(rpo3.x>ligne){ps9 = smoothstep(zp,0.,length(spo4(pr9s,ulif)));}

      pof = ps1+ps2+ps3+ps4+ps5+ps6+ps7+ps8+ps9; 
      }
              if(max(_pos2[0].z,max(max(_pos2[11].z,_pos2[10].z),max(_pos2[5].z,_pos2[6].z)))>0.4){
        float4 rpo  = rd4(_Time.y*trp);
        float4 rpo2 = rd4(_Time.y*trp+78.45);
        float4 rpo3 = rd4(_Time.y*trp+425.36);
          float2 p0 = _pos2[0].xy *re;
            float2 p1 = _pos2[9].xy *re;
            float2 p2 = _pos2[10].xy *re;
            float2 p3 = _pos2[13].xy *re;
            float2 p4 = _pos2[14].xy *re;
            float2 p0s = _pos2[0].xy *re;
            float2 p1s = _pos2[5].xy *re;
            float2 p4s = _pos2[6].xy *re;
            float2 p2s = _pos2[7].xy *re;
            float2 p5s = _pos2[8].xy *re;
            float2 p3s = _pos2[9].xy *re;
            float2 p6s = _pos2[10].xy *re;
            float2 p7s = _pos2[11].xy *re;
            float2 p8s = _pos2[12].xy *re;
            float2 p9s = _pos2[13].xy *re;
            float2 p11s = _pos2[14].xy *re;
            float2 p10s = _pos2[15].xy *re;
            float2 p12s = _pos2[16].xy *re;
      float2 pr0s[8];pr0s[0] = p1s;pr0s[1] = p2s;pr0s[2] = p3s;pr0s[3] = p7s;pr0s[4] = p6s;pr0s[5] = p5s;pr0s[6] = p4s;pr0s[7] = p0s;
      float2 pr2s[5];pr2s[0] = p0s;pr2s[1] = p3s;pr2s[2] = p10s;pr2s[3] = p12s;pr2s[4] = p6s;
      float2 pr3s[13];pr3s[0] =p0s;pr3s[1] = p1s;pr3s[2] = p2s;pr3s[3] = p3s;pr3s[4] = p7s;pr3s[5] = p9s;pr3s[6] = p10s;pr3s[7] = p12s;
      pr3s[8] =p11s;pr3s[9] = p8s;pr3s[10] = p6s;pr3s[11] = p5s;pr3s[12] = p4s;
      float2 pr4s[3];pr4s[0] = p1s;pr4s[1] = p2s;pr4s[2] = p3s;
      float2 pr5s[3];pr5s[0] = p4s;pr5s[1] = p5s;pr5s[2] = p6s;
      float2 pr6s[3];pr6s[0] = p7s;pr6s[1] = p8s;pr6s[2] = p10s;
      float2 pr7s[3];pr7s[0] = p8s;pr7s[1] = p11s;pr7s[2] = p12s;
      float2 pr8s[4];pr8s[0] = p1s;pr8s[1] = p7s;pr8s[2] = p8s;pr8s[3] = p4s;
      float2 pr9s[4];pr9s[0] = p1s;pr9s[1] = p10s;pr9s[2] = p12s;pr9s[3] = p4s;

      float ps1 = 0.;float ps2 = 0;float ps3 = 0.;float ps4 =0.;float ps5 = 0.;float ps6 = 0.;float ps7= 0.;float ps8 = 0.; float ps9 = 0.;
             if(rpo.x>ligne){ps1 = smoothstep(zp,0.,length(spo8(pr0s,ulif)));}
             if(rpo.y>ligne){ps2 = smoothstep(zp,0.,length(spo5(pr2s,ulif)));}
             if(rpo.z>ligne){ps3 = smoothstep(zp,0.,length(spo13(pr3s,ulif)));}
             if(rpo.w>ligne){ps4 = smoothstep(zp,0.,length(spo3(pr4s,ulif)));}
             if(rpo2.x>ligne){ps5 = smoothstep(zp,0.,length(spo3(pr5s,ulif)));}
             if(rpo2.y>ligne){ps6 = smoothstep(zp,0.,length(spo3(pr6s,ulif)));}
             if(rpo2.z>ligne){ps7 = smoothstep(zp,0.,length(spo3(pr7s,ulif)));}
             if(rpo2.w>ligne){ps8 = smoothstep(zp,0.,length(spo4(pr8s,ulif)));}
             if(rpo3.x>ligne){ps9 = smoothstep(zp,0.,length(spo4(pr9s,ulif)));}

      pof2 = ps1+ps2+ps3+ps4+ps5+ps6+ps7+ps8+ps9; 
      }
              if(max(_pos3[0].z,max(max(_pos3[11].z,_pos3[10].z),max(_pos3[5].z,_pos3[6].z)))>0.4){
        float4 rpo  = rd4(_Time.y*trp);
        float4 rpo2 = rd4(_Time.y*trp+78.45);
        float4 rpo3 = rd4(_Time.y*trp+425.36);
          float2 p0 = _pos3[0].xy *re;
            float2 p1 = _pos3[9].xy *re;
            float2 p2 = _pos3[10].xy *re;
            float2 p3 = _pos3[13].xy *re;
            float2 p4 = _pos3[14].xy *re;
            float2 p0s = _pos3[0].xy *re;
            float2 p1s = _pos3[5].xy *re;
            float2 p4s = _pos3[6].xy *re;
            float2 p2s = _pos3[7].xy *re;
            float2 p5s = _pos3[8].xy *re;
            float2 p3s = _pos3[9].xy *re;
            float2 p6s = _pos3[10].xy *re;
            float2 p7s = _pos3[11].xy *re;
            float2 p8s = _pos3[12].xy *re;
            float2 p9s = _pos3[13].xy *re;
            float2 p11s = _pos3[14].xy *re;
            float2 p10s = _pos3[15].xy *re;
            float2 p12s = _pos3[16].xy *re;
      float2 pr0s[8];pr0s[0] = p1s;pr0s[1] = p2s;pr0s[2] = p3s;pr0s[3] = p7s;pr0s[4] = p6s;pr0s[5] = p5s;pr0s[6] = p4s;pr0s[7] = p0s;
      float2 pr2s[5];pr2s[0] = p0s;pr2s[1] = p3s;pr2s[2] = p10s;pr2s[3] = p12s;pr2s[4] = p6s;
      float2 pr3s[13];pr3s[0] =p0s;pr3s[1] = p1s;pr3s[2] = p2s;pr3s[3] = p3s;pr3s[4] = p7s;pr3s[5] = p9s;pr3s[6] = p10s;pr3s[7] = p12s;
      pr3s[8] =p11s;pr3s[9] = p8s;pr3s[10] = p6s;pr3s[11] = p5s;pr3s[12] = p4s;
      float2 pr4s[3];pr4s[0] = p1s;pr4s[1] = p2s;pr4s[2] = p3s;
      float2 pr5s[3];pr5s[0] = p4s;pr5s[1] = p5s;pr5s[2] = p6s;
      float2 pr6s[3];pr6s[0] = p7s;pr6s[1] = p8s;pr6s[2] = p10s;
      float2 pr7s[3];pr7s[0] = p8s;pr7s[1] = p11s;pr7s[2] = p12s;
      float2 pr8s[4];pr8s[0] = p1s;pr8s[1] = p7s;pr8s[2] = p8s;pr8s[3] = p4s;
      float2 pr9s[4];pr9s[0] = p1s;pr9s[1] = p10s;pr9s[2] = p12s;pr9s[3] = p4s;

      float ps1 = 0.;float ps2 = 0;float ps3 = 0.;float ps4 =0.;float ps5 = 0.;float ps6 = 0.;float ps7= 0.;float ps8 = 0.; float ps9 = 0.;
             if(rpo.x>ligne){ps1 = smoothstep(zp,0.,length(spo8(pr0s,ulif)));}
             if(rpo.y>ligne){ps2 = smoothstep(zp,0.,length(spo5(pr2s,ulif)));}
             if(rpo.z>ligne){ps3 = smoothstep(zp,0.,length(spo13(pr3s,ulif)));}
             if(rpo.w>ligne){ps4 = smoothstep(zp,0.,length(spo3(pr4s,ulif)));}
             if(rpo2.x>ligne){ps5 = smoothstep(zp,0.,length(spo3(pr5s,ulif)));}
             if(rpo2.y>ligne){ps6 = smoothstep(zp,0.,length(spo3(pr6s,ulif)));}
             if(rpo2.z>ligne){ps7 = smoothstep(zp,0.,length(spo3(pr7s,ulif)));}
             if(rpo2.w>ligne){ps8 = smoothstep(zp,0.,length(spo4(pr8s,ulif)));}
             if(rpo3.x>ligne){ps9 = smoothstep(zp,0.,length(spo4(pr9s,ulif)));}

      pof3 = ps1+ps2+ps3+ps4+ps5+ps6+ps7+ps8+ps9; 
      }
                return  col + pof + pof2+pof3;
            }
            ENDCG
        }
    }
}
