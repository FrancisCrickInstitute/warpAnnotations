function fixed = apply_transformation3(landmarksPath, moving)
  import TransformPoints3.*     % required
  tp = TransformPoints3();
  fixed = tp.transform(landmarksPath, moving);      % object-directed function, must be called this way.
end