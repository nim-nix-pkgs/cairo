## This example show how to have real time cairo using glfw backend

import glfw, opengl, math
import cairo

let
  w: int32 = 256
  h: int32 = 256

var
  surface = imageSurfaceCreate(FORMAT_ARGB32, w, h)
  frameCount = 0
  window: Window

proc display() =
  ## Called every frame by main while loop

  # draw shiny sphere on gradient background
  var ctx = surface.create()
  var linerGradient = patternCreateLinear(0.0, 0.0,  0.0, 256.0)
  linerGradient.addColorStopRgba(1, 0, 0, 0, 1)
  linerGradient.addColorStopRgba(0, 1, 1, 1, 1)
  ctx.rectangle(0, 0, 256, 256)
  ctx.setSource(linerGradient)
  ctx.fill()
  var radialGradient  = patternCreateRadial(115.2, 102.4, 25.6, 102.4,  102.4, 128.0)
  radialGradient.addColorStopRgba(0, 1, 1, 1, 1)
  radialGradient.addColorStopRgba(1, 0, 0, 0, 1)
  ctx.setSource(radialGradient)
  ctx.arc(128.0, 128.0 + sin(float(frameCount)/10.0) * 20, 76.8, 0, 2 * PI)
  ctx.fill()

  # update texture with new pixels from surface
  var dataPtr = surface.getData()
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, GLsizei w, GLsizei h, GL_RGBA, GL_UNSIGNED_BYTE, dataPtr);

  # draw a quad over the whole screen
  glClear(GL_COLOR_BUFFER_BIT)
  glBegin(GL_QUADS);
  glTexCoord2d(0.0, 0.0); glVertex2d(-1.0, +1.0)
  glTexCoord2d(1.0, 0.0); glVertex2d(+1.0, +1.0)
  glTexCoord2d(1.0, 1.0); glVertex2d(+1.0, -1.0)
  glTexCoord2d(0.0, 1.0); glVertex2d(-1.0, -1.0)
  glEnd();

  inc frameCount
  glfw.swapBuffers(window)

glfw.initialize()
if GLFWError().error != getNoError:
  quit("Failed to Initialize GLFW: " & $GLFWError())

window = glfw.newWindow()
window.pos = (0, 0)
window.title = "Real time GLFW/Cairo example"
window.size = (cint w, cint h)

glfw.makeContextCurrent(window)
loadExtensions()

# allocate a texture and bind it
var dataPtr = surface.getData()
glTexImage2D(GL_TEXTURE_2D, 0, 3, GLsizei w, GLsizei h, 0, GL_RGBA, GL_UNSIGNED_BYTE, dataPtr);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
glEnable(GL_TEXTURE_2D);

while window.shouldClose() == false:
  glfw.pollEvents()
  display()
