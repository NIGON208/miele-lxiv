#ifndef __OsiriXFixedPointVolumeRayCastMapper_h
#define __OsiriXFixedPointVolumeRayCastMapper_h

#include "vtkFixedPointVolumeRayCastMapper.h"

class  VTKRENDERINGVOLUME_EXPORT OsiriXFixedPointVolumeRayCastMapper : public vtkFixedPointVolumeRayCastMapper
{
    virtual const char* GetClassNameInternal() const { return "OsiriXFixedPointVolumeRayCastMapper"; }

public:
  static OsiriXFixedPointVolumeRayCastMapper *New();
  void Render( vtkRenderer *, vtkVolume * );

protected:
	OsiriXFixedPointVolumeRayCastMapper();

private:
  OsiriXFixedPointVolumeRayCastMapper(const OsiriXFixedPointVolumeRayCastMapper&);  // Not implemented.
  void operator=(const OsiriXFixedPointVolumeRayCastMapper&);  // Not implemented.
};
#endif
