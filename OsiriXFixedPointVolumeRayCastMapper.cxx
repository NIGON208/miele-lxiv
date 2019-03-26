#include "OsiriXFixedPointVolumeRayCastMapper.h"

#include "vtkObjectFactory.h"
#include "vtkRenderWindow.h"
#include "vtkRenderer.h"
#include "vtkTimerLog.h"
#include "vtkOpenGLRenderWindow.h"
#include <math.h>

bool dontRenderVolumeRenderingOsiriX = false;

vtkStandardNewMacro(OsiriXFixedPointVolumeRayCastMapper);

OsiriXFixedPointVolumeRayCastMapper::OsiriXFixedPointVolumeRayCastMapper()
{

}

// See VTK's vtkFixedPointVolumeRayCastMapper.cxx
void OsiriXFixedPointVolumeRayCastMapper::Render( vtkRenderer *ren, vtkVolume *vol )
{
  this->Timer->StartTimer();

  // Since we are passing in a value of 0 for the multiRender flag
  // (this is a single render pass - not part of a multipass AMR render)
  // then we know the origin, spacing, and extent values will not
  // be used so just initialize everything to 0. No need to check
  // the return value of the PerImageInitialization method - since this
  // is not a multirender it will always return 1.
  double dummyOrigin[3]  = {0.0, 0.0, 0.0};
  double dummySpacing[3] = {0.0, 0.0, 0.0};
  int dummyExtent[6] = {0, 0, 0, 0, 0, 0};
  this->PerImageInitialization( ren, vol, 0,
				dummyOrigin,
				dummySpacing,
				dummyExtent );

  this->PerVolumeInitialization( ren, vol );

  vtkRenderWindow *renWin=ren->GetRenderWindow();

#if 0 /// @@@ TBC
    vtkOpenGLRenderWindow *rw = (vtkOpenGLRenderWindow *)renWin;
    //if (!rw->Initialized)
        rw->OpenGLInit();
#endif
    
  if ( renWin && renWin->CheckAbortStatus() )
  {
    this->AbortRender();
    return;
  }

  this->PerSubVolumeInitialization( ren, vol, 0 );
  if ( renWin && renWin->CheckAbortStatus() )
  {
    this->AbortRender();
    return;
  }

  if (!dontRenderVolumeRenderingOsiriX)  // Our addition
	this->RenderSubVolume();

  if ( renWin && renWin->CheckAbortStatus() )
  {
    this->AbortRender();
    return;
  }

#ifndef NDEBUG
    this->DebugOn();
    vtkIndent *indent = vtkIndent::New();
    std::cerr << this->GetClassName() << std::endl;
    this->PrintSelf(std::cout, *indent);
    //this->ImageDisplayHelper->PrintSelf(std::cout, *indent);
    //int dataType;
    //this->ImageDisplayHelper->TextureObject->GetDataType(dataType);
#endif  
    
#if 1 // @@@ debug
    //this->ImageDisplayHelper->RenderTexture(0,0,0,0);;
#endif
    
  this->DisplayRenderedImage( ren, vol );

  this->Timer->StopTimer();
  this->TimeToDraw = this->Timer->GetElapsedTime();
  // If we've increased the sample distance, account for that in the stored time. Since we
  // don't get linear performance improvement, use a factor of .66
  this->StoreRenderTime( ren, vol,
			 this->TimeToDraw *
			 this->ImageSampleDistance *
			 this->ImageSampleDistance *
			 ( 1.0 + 0.66*
			   (this->SampleDistance - this->OldSampleDistance) /
			   this->OldSampleDistance ) );

  this->SampleDistance = this->OldSampleDistance;
}
