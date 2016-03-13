/**********************************************************************
 *
 *  CS 4554 assignment 6
 *  Fall 2014
 *
 *
 *
 **********************************************************************/

#ifdef __APPLE__
#include <OpenGL/OpenGL.h>
#include <Glut/glut.h>
#import <Foundation/Foundation.h>
#import <AppKit/NSImage.h>
#import "Vec3.h"
#import "PolyModel.h"
#import "textfile.h"
#import "Mat3x3.h"
#else
#include <GL/glut.h>
#endif

#include <string>
#include <math.h>
#include <iostream>
#include <fstream>




using namespace std;
/* ascii codes for special keys */
#define ESCAPE 27

/**********************************************************************
 * Configuration
 **********************************************************************/

#define INITIAL_WIDTH 600
#define INITIAL_HEIGHT 600
#define INITIAL_X_POS 100
#define INITIAL_Y_POS 100

#define WINDOW_NAME     "Assignment 6"
#define RESOURCE_DIR   "/Users/dc10/Desktop/YuezhuMa_Assignment6/resources/"

/**********************************************************************
 * Globals
 **********************************************************************/

GLsizei window_width;
GLsizei window_height;

GLuint m_floor_texture_id;
GLuint m_wall_texture_id;

GLint symbol1 = 1;
GLint symbol2 = 1;

int g_frameIndex = 0;

Model g_model;
Model g_model2;

vec3 view_dir;
vec3 view_pos;
vec3 object_delta(0.0f,0.0f,0.0f);

//view point
GLfloat xEye = view_pos.x;
GLfloat yEye = view_pos.y;
GLfloat zEye = view_pos.z;


//get shader sources

char *latticeVertexShaderSource;
char *latticeFragmentShadeSource;

char *latticeVertexShaderSource2;
char *latticeFragmentShadeSource2;

GLfloat angle = 0.0;
GLfloat angle1 = 0.0;
GLfloat scaleNum = 1.0;
GLfloat xMove = 0.0;
GLfloat zMove = 0.0;
/**********************************************************************
 * Set the new size of the window
 **********************************************************************/

void resize_scene(GLsizei width, GLsizei height)
{
    glViewport(0, 0, width, height);  /* reset the current viewport and 
                                       * perspective transformation */
    window_width  = width;
    window_height = height;
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	gluPerspective( 45.0f, (float)width / (float)height, 0.1f, 100.0f );
    glMatrixMode(GL_MODELVIEW);
    
}

/**********************************************************************
 * Load an image and return a texture id or 0 on failure
 **********************************************************************/
GLuint getTextureFromFile(const char *fname)
{
    NSString *str = [[NSString alloc] initWithCString:fname];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:str];
    
    if (![image isValid])
        return 0;
    int texformat = GL_RGB;
    NSBitmapImageRep * imgBitmap =[ [ NSBitmapImageRep alloc ]initWithData: [ image TIFFRepresentation ] ];
    switch( [ imgBitmap samplesPerPixel ] )        
    {
        case 4:texformat = GL_RGBA;
            break;
        case 3:texformat = GL_RGB;
            break;
        case 2:texformat = GL_LUMINANCE_ALPHA;
            break;
        case 1:texformat = GL_LUMINANCE;
            break;
        default:
            break;
    }
    
    
    GLuint tex_id;
    
    glGenTextures (1, &tex_id);
    glBindTexture(GL_TEXTURE_2D, tex_id);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, texformat, [image size].width, [image size].height, 
                 0, texformat, GL_UNSIGNED_BYTE, [ imgBitmap bitmapData ]);
    
    
    return tex_id;
}


/**********************************************************************
 * any program initialization (set initial OpenGL state, 
 **********************************************************************/
void init()
{
    
    string ifile = RESOURCE_DIR + string("brick_color_map.png");
    string ifile2 = RESOURCE_DIR + string("bricks.png");
    
    m_floor_texture_id = getTextureFromFile(ifile.c_str());
    m_wall_texture_id = getTextureFromFile(ifile2.c_str());
    
    g_model.LoadModel("/Users/dc10/Desktop/YuezhuMa_Assignment6/resources/cow.d2");
    
    
    view_dir.set(0.0f, 0.0f, -1.0f);
    view_pos.x = 0.0;
    view_pos.y = 1.0;
    view_pos.z = -5.0;

    
    
    latticeVertexShaderSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Phong.vertex");
    latticeFragmentShadeSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Phong.fragment");
 
   
 
}

/**********************************************************************
 * The main drawing functions.
 **********************************************************************/
void draw_scene(void)
{
    
    
    /* clear the screen and the depth buffer */
    glClearColor (0.0, 0.0, 0.0, 0.0);
	glClearDepth ( 1.0 );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable( GL_DEPTH_TEST );
    
    /* reset modelview matrix */
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    gluLookAt(view_pos.x, view_pos.y, view_pos.z,
              view_pos.x+view_dir.x, view_pos.y+view_dir.y, view_pos.z+view_dir.z,
              0.0f, 1.0f, 0.0f);
    
	glColor3f(1.0, 1.0, 1.0f);
    
    
    
    //floor
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, m_floor_texture_id);
    
    glBegin(GL_QUADS);
    
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(-4.0f,-1.0f, -1.0f);
    
    glTexCoord2f(8.0f, 0.0f);
    glVertex3f(4.0, -1.0f, -1.0f);
    
    glTexCoord2f(8.0f, 8.0f);
    glVertex3f(4.0, -1.0f, -9.0);
    
    glTexCoord2f(0.0f, 8.0f);
    glVertex3f(-4.0f, -1.0f, -9.0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //ceiling
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, m_floor_texture_id);
    
    glBegin(GL_QUADS);
    
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(-4.0f,3.0f, -1.0f);
    
    glTexCoord2f(5.0f, 0.0f);
    glVertex3f(4.0, 3.0f, -1.0f);
    
    glTexCoord2f(5.0f, 5.0f);
    glVertex3f(4.0, 3.0f, -9.0);
    
    glTexCoord2f(0.0f, 5.0f);
    glVertex3f(-4.0f, 3.0f, -9.0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    
    //wall
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id);
    
    glBegin(GL_QUADS);
    
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(-4.0f,-1.0f, -1.0f);
    
    glTexCoord2f(8.0f, 0.0f);
    glVertex3f(-4.0, -1.0f, -9.0f);
    
    glTexCoord2f(8.0f, 4.0f);
    glVertex3f(-4.0, 3.0f, -9.0);
    
    glTexCoord2f(0.0f, 4.0f);
    glVertex3f(-4.0f, 3.0f, -1.0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id);
    
    glBegin(GL_QUADS);
    
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(-4.0f,-1.0f, -9.0f);
    
    glTexCoord2f(8.0f, 0.0f);
    glVertex3f(4.0, -1.0f, -9.0f);
    
    glTexCoord2f(8.0f, 4.0f);
    glVertex3f(4.0, 3.0f, -9.0);
    
    glTexCoord2f(0.0f, 4.0f);
    glVertex3f(-4.0f, 3.0f, -9.0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id);
    
    glBegin(GL_QUADS);
    
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(4.0f,-1.0f, -9.0f);
    
    glTexCoord2f(8.0f, 0.0f);
    glVertex3f(4.0, -1.0f, -1.0f);
    
    glTexCoord2f(8.0f, 4.0f);
    glVertex3f(4.0, 3.0f, -1.0);
    
    glTexCoord2f(0.0f, 4.0f);
    glVertex3f(4.0f, 3.0f, -9.0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id);
    
    glBegin(GL_QUADS);
    
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(4.0f,-1.0f, -1.0f);
    
    glTexCoord2f(8.0f, 0.0f);
    glVertex3f(-4.0, -1.0f, -1.0f);
    
    glTexCoord2f(8.0f, 4.0f);
    glVertex3f(-4.0, 3.0f, -1.0);
    
    glTexCoord2f(0.0f, 4.0f);
    glVertex3f(4.0f, 3.0f, -1.0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    

    
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_LIGHT1);
    
    GLfloat LightAmbient[]	= { 0.2f, 0.2f, 0.2f, 1.0f };
	GLfloat LightDiffuse[]	= { 0.6f, 0.6f, 0.6f, 1.0f };
	GLfloat LightSpecular[]	= { 0.8f, 0.8f, 0.8f, 1.0f };
	GLfloat LightPosition1[] = { 3.0f, 2.0f, -1.0f, 1.0f };
    GLfloat LightDiffuse2[]	= { 0.8f, 0.0f, 0.0f, 1.0f };
    GLfloat LightPosition2[] = { -3.0f, 2.0f, -8.0f, 1.0f };
    
    glLightfv(GL_LIGHT0, GL_AMBIENT , LightAmbient );
	glLightfv(GL_LIGHT0, GL_DIFFUSE , LightDiffuse );
	glLightfv(GL_LIGHT0, GL_SPECULAR, LightSpecular);
	glLightfv(GL_LIGHT0, GL_POSITION, LightPosition1);
    
    
     glLightfv(GL_LIGHT1, GL_AMBIENT , LightAmbient );
     glLightfv(GL_LIGHT1, GL_DIFFUSE , LightDiffuse2 );
     glLightfv(GL_LIGHT1, GL_SPECULAR, LightSpecular);
     glLightfv(GL_LIGHT1, GL_POSITION, LightPosition2);
    
    // surface material attributes
	GLfloat material_Ka[]	= { 0.2f, 0.2f, 0.2f, 1.0f };
	GLfloat material_Kd[]	= { 0.8f, 0.6f, 0.6f, 1.0f };
	GLfloat material_Ks[]	= { 0.2f, 0.2f, 0.2f, 1.0f };
	GLfloat material_Ke[]	= { 0.2f, 0.2f, 0.2f, 1.0f };
	GLfloat material_Se		= 15;
    
	glMaterialfv(GL_FRONT, GL_AMBIENT	, material_Ka);
	glMaterialfv(GL_FRONT, GL_DIFFUSE	, material_Kd);
	glMaterialfv(GL_FRONT, GL_SPECULAR	, material_Ks);
	glMaterialfv(GL_FRONT, GL_EMISSION	, material_Ke);
	glMaterialf (GL_FRONT, GL_SHININESS	, material_Se);
    


    

    GLhandleARB latticeVertexShader, latticeFragmentShader;
    latticeVertexShader = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
    latticeFragmentShader = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
    
    glShaderSourceARB(latticeVertexShader, 1, &latticeVertexShaderSource, NULL);
    glShaderSourceARB(latticeFragmentShader, 1, &latticeFragmentShadeSource, NULL);
    
    glCompileShaderARB(latticeVertexShader);
    glCompileShaderARB(latticeFragmentShader);
    
    GLhandleARB shaderProgram;
    shaderProgram = glCreateProgramObjectARB();
 
    glAttachObjectARB(shaderProgram, latticeVertexShader);
    glAttachObjectARB(shaderProgram, latticeFragmentShader);
    
    glLinkProgramARB(shaderProgram);
    
    glUseProgramObjectARB(shaderProgram);
    glTranslatef(0.0, -0.4, -5.0);
  
    glRotatef(angle, 0.0, 1.0, 0.0);
    glRotatef(angle1, 1.0, 0.0, 0.0);
    glScalef(scaleNum, scaleNum, scaleNum);
    g_model.Paint();
    glUseProgram(0);
    

    glDisable(GL_LIGHTING);
    glDisable(GL_CULL_FACE);

    glutSwapBuffers();
}

/**********************************************************************
 * this function is called whenever a key is pressed
 **********************************************************************/
void key_press(unsigned char key, int x, int y)
{
    float speed = 0.1f;
    vec3 c(0.0f,1.0f,0.0f);
    switch (key) {
        case 'w':
        {
            view_pos += view_dir*speed;
            break;
        }
        case 's':
        {
            view_pos -= view_dir*speed;
            break;
        }
            
        case 'a':
        {
            view_pos += c.cross(view_dir)*speed;
            
            break;
        }
        case 'd':
        {
            view_pos += view_dir.cross(c)*speed;
            
            break;
        }
        case 'i':  // rotate up
        {
            angle1 -=5;
            break;
        }
        case 'k':
        {
            angle += 5;
        
            break;
        }
        case 'j':
        {
            angle -= 5;
        
            break;
        }
        case 'm':
        {
            angle1 += 5;
        
            break;
        }

        case '+':
        {
            //scale
            scaleNum += 0.1;
        
            break;
        }
        case '-':
        {
            //scale
            scaleNum -= 0.1;
            break;
        }
    
        case '1':
        {
            
            latticeVertexShaderSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/shader1.vertex");
            latticeFragmentShadeSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/shader1.fragment");
            break;
        }
        case '2':
        {
            latticeVertexShaderSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/shader2.vertex");
            latticeFragmentShadeSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/shader2.fragment");
            
            break;
        }
        case '3':
        {
            
            latticeVertexShaderSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Toon.vertex");
            latticeFragmentShadeSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Toon.fragment");
            
            break;
        }
            
        case '4':
        {
            
            latticeVertexShaderSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Gouraud.vertex");
            latticeFragmentShadeSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Gouraud.fragment");
            
            break;
        }
            
        case '5':
        {
            
            latticeVertexShaderSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Phong.vertex");
            latticeFragmentShadeSource = textFileRead("/Users/dc10/Desktop/YuezhuMa_Assignment6/Phong.fragment");
            
            break;
        }

        default:
            break;
    }

}





/**********************************************************************
 * this function is called for non-standard keys like up/down/left/right
 * arrows.
 **********************************************************************/
void special_key(int key, int x, int y)
{
    float angle_delta = 0.02f;
    Mat3x3 m;
    
    
    switch (key) {
        case GLUT_KEY_RIGHT: //right arrow
            m.setRotY(-angle_delta);
            view_dir = m * view_dir;
            break;
        case GLUT_KEY_LEFT: //left arrow
            m.setRotY(angle_delta);
            view_dir = m * view_dir;
            break;
        case GLUT_KEY_DOWN: //down arrow
            m.setRotX(angle_delta);
            view_dir = m * view_dir;
            break;
        case GLUT_KEY_UP: //up arrow
            m.setRotX(-angle_delta);
            view_dir = m * view_dir;
            break;
        default:
            break;
    }
    
    view_dir.normalize();
    
    glutPostRedisplay();
    
}

//================================
// timer : triggered every 16ms ( about 60 frames per second )
//================================
void timer( int value ) {
	// increase frame index
	g_frameIndex++;

	
	// render
	glutPostRedisplay();
    
	// reset timer
	glutTimerFunc( 16, timer, 0 );
}


int main(int argc, char * argv[]) 
{
    
  	/* Initialize GLUT */
    glutInit(&argc, argv);  
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);  
    glutInitWindowSize(INITIAL_WIDTH, INITIAL_HEIGHT);  
    glutInitWindowPosition(INITIAL_X_POS, INITIAL_Y_POS);  
    glutCreateWindow(WINDOW_NAME);  
    
    /* Register callback functions */
	glutDisplayFunc(draw_scene);     
    glutReshapeFunc(resize_scene);       //Initialize the viewport when the window size changes.
    glutKeyboardFunc(key_press);         //handle when the key is pressed
	glutSpecialFunc(special_key);        //Special Keyboard Key fuction(For Arrow button and F1 to F10 button)
    glutTimerFunc( 16, timer, 0 );
    
    /* OpenGL and other program initialization */
    init();
    /* Enter event processing loop */
    glutMainLoop();  
    
    return 1;
}



