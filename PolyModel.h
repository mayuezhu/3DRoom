#import "textfile.h"
class ModelFace {
public :
	int		numSides;
	int *	indices;

public :
	ModelFace() {
		numSides = 0;
		indices = NULL;
	}

	~ModelFace() {
		if ( indices ) {
			delete[] indices;
			indices = NULL;
		}
		numSides = 0;
	}
};


class Model {
public :
	int			numVerts;
	vec3 *		verts;

	int			numFaces;
	ModelFace *	faces;

public :
	Model() {
		numVerts = 0;
		verts = NULL;

		numFaces = 0;
		faces = NULL;
	}

	~Model() {
		if ( verts ) {
			delete[] verts;
			verts = NULL;
		}
		numVerts = 0;

		if ( faces ) {
			delete[] faces;
			faces = NULL;
		}
		numFaces = 0;
	}

	void DrawEdges( void ) {
		glBegin( GL_LINES );
		for ( int i = 0; i < numFaces; i++ ) {
			for ( int k = 0; k < faces[ i ].numSides; k++ ) {
				int p0 = faces[ i ].indices[ k ];
				int p1 = faces[ i ].indices[ ( k + 1 ) % faces[ i ].numSides ];
				glVertex3fv( verts[ p0 ].ptr() );
				glVertex3fv( verts[ p1 ].ptr() );
			}
		}
		glEnd();
	}

	void DrawEdges2D( void ) {
		glBegin( GL_LINES );
		for ( int i = 0; i < numFaces; i++ ) {
			for ( int k = 0; k < faces[ i ].numSides; k++ ) {
				int p0 = faces[ i ].indices[ k ];
				int p1 = faces[ i ].indices[ ( k + 1 ) % faces[ i ].numSides ];
				glVertex2fv( verts[ p0 ].ptr() );
				glVertex2fv( verts[ p1 ].ptr() );
			}
		}
		glEnd();
	}

    
    //compute the normal of a certain face
    void  calculateNormal (int p0, int p1, int p2)
    {
        vec3 edge1 = verts[p1] - verts[p0];
        vec3 edge2 = verts[p2] - verts[p1];
        
        //calculate the cross product result of two edges
        float xNormal = edge1.y * edge2.z - edge1.z * edge2.y;
        float yNormal = edge1.z * edge2.x - edge1.x * edge2.z;
        float zNormal = edge1.x * edge2.y - edge1.y * edge2.x;
        
        //add the faces' normal to every vertiecs
        verts[p0].setNormal(xNormal, yNormal, zNormal);
        verts[p1].setNormal(xNormal, yNormal, zNormal);
        verts[p2].setNormal(xNormal, yNormal, zNormal);
        
        
    }
    
    void Paint( void )
    {
        
        //calculate the normals of every verticies
        for ( int i = 0; i < numFaces; i++ ) {

            int p0 = faces[ i ].indices[ 0 ];
            int p1 = faces[ i ].indices[ 1 ];
            int p2 = faces[ i ].indices[ 2 ];
            
            calculateNormal(p0, p1, p2);  
		}
        
        //normalized 
        for ( int i = 0; i < numVerts; i++ ) {
            verts[i].normalize();
        }
        
		for ( int i = 0; i < numFaces; i++ ) {

            glFrontFace(GL_CW);
            glBegin( GL_TRIANGLES );
            int p0 = faces[ i ].indices[ 0 ];
            int p1 = faces[ i ].indices[ 1 ];
            int p2 = faces[ i ].indices[ 2 ];
            glNormal3fv( verts[ p0 ].normal());
            glVertex3fv( verts[ p0 ].ptr() );
            glNormal3fv( verts[ p1 ].normal());
            glVertex3fv( verts[ p1 ].ptr() );
            glNormal3fv( verts[ p2 ].normal());
            glVertex3fv( verts[ p2 ].ptr() );
            glEnd();

        
		}
		
 
    }
	// calculate AABB
	bool Bound( vec3 &min, vec3 &max ) {
		if ( numVerts <= 0 ) {
			return false;
		}

		min = verts[ 0 ];
		max = verts[ 0 ];

		for ( int i = 1; i < numVerts; i++ ) {
			vec3 v = verts[ i ];

			if ( v.x < min.x ) {
				min.x = v.x;
			} else if ( v.x > max.x ) {
				max.x = v.x;
			}

			if ( v.y < min.y ) {
				min.y = v.y;
			} else if ( v.y > max.y ) {
				max.y = v.y;
			}

			if ( v.z < min.z ) {
				min.z = v.z;
			} else if ( v.z > max.z ) {
				max.z = v.z;
			}
		}

		return true;
	}

	// scale the model into the range of [ -1, 1 ]
	void ResizeModel( void ) {
		// bound
		vec3 min, max;
		if ( !Bound( min, max ) ) {
			return;
		}

		// center
		vec3 center = ( min + max ) * 0.5f;

		// scale factor
		vec3 size = ( max - min ) * 0.5f;

		float r = size.x;
		if ( size.y > r ) {
			r = size.y;
		}
		if ( size.z > r ) {
			r = size.z;
		}

		if ( r < 1e-6f ) {
			r = 0;
		} else {
			r = 1.0f / r;
		}

		// scale to [ -1, 1 ]
		for ( int i = 0; i < numVerts; i++ ) {
			verts[ i ] -= center;
			verts[ i ] *= r;
		}
	}

	// scale model
	void Scale( float r ) {
		for ( int i = 0; i < numVerts; i++ ) {
			verts[ i ] *= r;
		}
	}

	void Translate( const vec3 &offset ) {
		// translate ...
	}

	void Rotate( float angle ) {
		// rotate ...
	}

	// load model from .d file
	bool LoadModel( const char *path ) {
		if ( !path ) {
			return false;
		}

		// open file
		FILE *fp = fopen( path, "r" );
		if ( !fp ) {
			return false;
		}

		// num of vertices and indices
		fscanf( fp, "data%d%d", &numVerts, &numFaces );

		// alloc vertex and index buffer
		verts = new vec3[ numVerts ];
		faces = new ModelFace[ numFaces ];

		// read vertices
		for ( int i = 0; i < numVerts; i++ ) {
			fscanf( fp, "%f%f%f", &verts[ i ].x, &verts[ i ].y, &verts[ i ].z );
		}

		// read indices
		for ( int i = 0; i < numFaces; i++ ) {
			ModelFace *face = &faces[ i ];

			fscanf( fp, "%i", &face->numSides );
			faces[ i ].indices = new int[ face->numSides ];

			for ( int k = 0; k < face->numSides; k++ ) {
				fscanf( fp, "%i", &face->indices[ k ] );
			}
		}

		// close file
		fclose( fp );

		ResizeModel();

		return true;
	}
};
