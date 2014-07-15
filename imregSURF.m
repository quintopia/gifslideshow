function warped = imregSURF(change, keep)
% IMREGSURF Register and crop an RGB image to the field of view of another RGB image
%   
%   WARPED = IMREGSURF(CHANGE, KEEP) spatially registers CHANGE with KEEP 
%   using their SURF features, returning a transformed copy of CHANGE
%   cropped into the field of view and bounding box of KEEP. In addition,
%   the copy will be color-adjusted to match the histogram of KEEP. This
%   will work best if any especially light or dark parts of CHANGE which do
%   not also appear in KEEP are pre-cropped. The output WARPED will be the
%   same size as KEEP, and will be black anywhere the field of view of
%   CHANGE did not overlap that of KEEP.
%
%   See also IMHISTMATCH, DETECTSURFFEATURES, IMWARP
    moving = rgb2gray(change);
    fixed = rgb2gray(keep);
    change = imhistmatch(change,keep,128);
    ptsOriginal = detectSURFFeatures(fixed);
    ptsDistorted = detectSURFFeatures(moving);
    [featuresOriginal, validPtsOriginal] = extractFeatures(fixed, ptsOriginal);
    [featuresDistorted, validPtsDistorted] = extractFeatures(moving, ptsDistorted);
    index_pairs = matchFeatures(featuresOriginal, featuresDistorted);
    matchedPtsOriginal = validPtsOriginal(index_pairs(:,1));
    matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
    [tform,~,~] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'affine');
    outputView = imref2d(size(fixed));
    warped = imwarp(change,tform,'OutputView',outputView);