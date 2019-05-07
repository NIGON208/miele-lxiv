//
//  ©Alex Bettarini -- all rights reserved
//  License GPLv3.0 -- see License File
//
//  At the end of 2014 the project was forked from OsiriX to become Miele-LXIV
//  The original version of this file had no header

#ifndef __OsiriXFixedPointVolumeRayCastMapper_h
#define __OsiriXFixedPointVolumeRayCastMapper_h

#include "vtkFixedPointVolumeRayCastMapper.h"

class VTKRENDERINGVOLUME_EXPORT OsiriXFixedPointVolumeRayCastMapper : public vtkFixedPointVolumeRayCastMapper
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
