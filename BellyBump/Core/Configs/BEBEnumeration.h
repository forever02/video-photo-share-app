#pragma once


typedef NS_ENUM(NSUInteger, BEBDetectFaceSimilarType) {
    BEBDetectFaceSimilarNone = -1,
    BEBDetectFaceSimilar = 0,
    BEBDetectFaceSimilarMoveLeft = 1,
    BEBDetectFaceSimilarMoveRight = 2,
    BEBDetectFaceSimilarMoveUp = 4,
    BEBDetectFaceSimilarMoveDown = 8,
    BEBDetectFaceSimilarMoveUpLeft = BEBDetectFaceSimilarMoveUp + BEBDetectFaceSimilarMoveLeft,
    BEBDetectFaceSimilarMoveUpRight = BEBDetectFaceSimilarMoveUp + BEBDetectFaceSimilarMoveRight,
    BEBDetectFaceSimilarMoveDownLeft = BEBDetectFaceSimilarMoveDown + BEBDetectFaceSimilarMoveLeft,
    BEBDetectFaceSimilarMoveDownRight = BEBDetectFaceSimilarMoveDown + BEBDetectFaceSimilarMoveRight,
    BEBDetectFaceSimilarMoveIn = 16,
    BEBDetectFaceSimilarMoveOut = 17
};

typedef NS_ENUM(NSUInteger, BEBFrequencyType) {
    FrequencyTypeDaily = 0,
    FrequencyTypeBiweekly,
    FrequencyTypeWeekly,
};


typedef NS_ENUM(NSUInteger, BEBStoryType) {
    StoryTypeFullShot = 0,
    StoryTypeMediumShot,
    StoryTypeDetailShot,    // Equal SelfFile for Pregnant
    StoryType180Degree
};

typedef NS_ENUM(NSUInteger, BEBGenderType) {
    GenderBoy = 0,
    GenderGirl,
    GenderSuprise,
};

typedef NS_ENUM(NSUInteger, BEBCreateVideoTabSelectionType) {
    BEBCreateVideoTabSelectionTypeFont,
    BEBCreateVideoTabSelectionTypeMusic,
    BEBCreateVideoTabSelectionTypeFPS
};

typedef NS_ENUM(NSUInteger, BEBEditImageTabSelectionType) {
    BEBEditImageTabSelectionTypeFont,
    BEBEditImageTabSelectionTypeCropSize
};

typedef enum {
    GPUIMAGE_NONE,
    GPUIMAGE_GRAYSCALE,
    GPUIMAGE_VIGNETTE,
    GPUIMAGE_BOXBLUR,
    GPUIMAGE_MONOCHROMEYELLOW,
    GPUIMAGE_MONOCHROMECYAN,
    GPUIMAGE_POSTERIZE,
    GPUIMAGE_MONOCHROMEPURPLE2,
    GPUIMAGE_SATURATION,
    GPUIMAGE_CONTRAST,
    GPUIMAGE_BRIGHTNESS,
    GPUIMAGE_LEVELS,
    GPUIMAGE_EXPOSURE,
    GPUIMAGE_HUE,
    GPUIMAGE_WHITEBALANCE,
    GPUIMAGE_MONOCHROMERED,
    GPUIMAGE_MONOCHROMEGREEN,
    GPUIMAGE_MONOCHROMEBLUE,
    GPUIMAGE_MONOCHROMEPURPLE1,
    GPUIMAGE_MONOCHROMEORANGE,
    GPUIMAGE_TONECURVE,
    GPUIMAGE_HIGHLIGHTSHADOW,
    GPUIMAGE_HALFTONE,
    GPUIMAGE_SEPIA,
    GPUIMAGE_PIXELLATE,
    GPUIMAGE_POLARPIXELLATE,
    GPUIMAGE_PIXELLATE_POSITION,
    GPUIMAGE_SMOOTHTOON,
    GPUIMAGE_EMBOSS,
    GPUIMAGE_PINCH,
    GPUIMAGE_DILATION,
    GPUIMAGE_UIELEMENT,
    GPUIMAGE_NUMFILTERS,
    
    GPUIMAGE_MONOCHROMESUMMER,
    GPUIMAGE_MONOCHROMESOFTBLUE,
    GPUIMAGE_NATURAL
    
} GPUImageShowcaseFilterType;
