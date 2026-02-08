# Copyright 2024 SC_PGO_ROS2 Contributors
# SPDX-License-Identifier: BSD-3-Clause

"""Utilities for working with PCD (Point Cloud Data) files using pypcd library."""

import numpy as np
# for the install, use this command: python3.x (use your python ver) -m
# pip install --user git+https://github.com/DanielPollithy/pypcd.git
from pypcd import pypcd


def make_xyzi_point_cloud(xyzl, label_type='f'):
    """Create a point cloud with XYZI (position + intensity) fields from a numpy array.

    Converts a numpy array containing 3D positions and intensity values into a
    pypcd PointCloud object suitable for writing to PCD files. The intensity
    field can be encoded as either float (F) or unsigned int (U) type.

    Args:
        xyzl: Numpy array of shape (N, 4) where columns are [x, y, z, intensity].
        label_type: Type encoding for intensity field. Either 'f' for float32 or
            'u' for uint8. Defaults to 'f'.

    Returns:
        pypcd.PointCloud: Point cloud object with x, y, z, and intensity fields.

    Raises:
        ValueError: If label_type is not 'f' or 'u'.
    """
    md = {'version': .7,
          'fields': ['x', 'y', 'z', 'intensity'],
          'count': [1, 1, 1, 1],
          'width': len(xyzl),
          'height': 1,
          'viewpoint': [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
          'points': len(xyzl),
          'data': 'ASCII'}
    if label_type.lower() == 'f':
        md['size'] = [4, 4, 4, 4]
        md['type'] = ['F', 'F', 'F', 'F']
    elif label_type.lower() == 'u':
        md['size'] = [4, 4, 4, 1]
        md['type'] = ['F', 'F', 'F', 'U']
    else:
        raise ValueError('label type must be F or U')
    # TODO use .view()
    xyzl = xyzl.astype(np.float32)
    dt = np.dtype([('x', np.float32), ('y', np.float32), ('z', np.float32),
                   ('intensity', np.float32)])
    pc_data = np.rec.fromarrays([xyzl[:, 0], xyzl[:, 1], xyzl[:, 2],
                                 xyzl[:, 3]], dtype=dt)
    pc = pypcd.PointCloud(md, pc_data)
    return pc
