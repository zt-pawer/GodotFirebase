#ifndef GODOT_FIREBASE_STUB_H
#define GODOT_FIREBASE_STUB_H

#include "gdextension_interface.h"

#if defined(_WIN32)
#define GF_STUB_EXPORT __declspec(dllexport)
#else
#define GF_STUB_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

GF_STUB_EXPORT GDExtensionBool godot_firebase_start(
    GDExtensionInterfaceGetProcAddress p_get_proc_address,
    GDExtensionClassLibraryPtr p_library,
    GDExtensionInitialization *r_initialization
);

#ifdef __cplusplus
}
#endif

#endif
