#pragma once

/** PLEASE READ THIS BELOW NOTES BEFORE CHANGE ANYTHING IN THIS FILE
 *
 * if you need to add new configuration, please add and sort the configuration
 * ascending to make it easier to be found in the future
 *
 * for most of the configuration, you just need to switch the IS_SANDBOX flag
 * read more how to switch it
 */

/**
 * Comment this define to make the settings to be production settings
 *
 * and (if needed)
 * please change the facebook id in the info.plist file
 * please change the bundle id in the info.plist file
 * please change the profiling if needed
 * please change the bundle name if needed
 *
 */
#define IS_SANDBOX 1

///**
// * BellyBump URL String
// */
#if IS_SANDBOX
    #define BellyBumpURLString @"http://54.69.74.89:8000/api/v1/"
#else
    #define BellyBumpURLString @"http://54.69.74.89:8000/api/v1/"
#endif
