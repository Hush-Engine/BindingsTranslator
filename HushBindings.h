#pragma once
// NOLINTBEGIN
#include <stdbool.h>
#include <stdint.h>


#ifdef __cplusplus
extern "C" {
#endif

typedef uint64_t Hush__Entity_EntityId;
typedef void (*Hush__ObserverCallback_t)(Hush__Entity_EntityId, void *);
typedef uint32_t Hush__ComponentTraits__EComponentOpsFlags;
#define Hush__ComponentTraits__EComponentOpsFlags_None 0
#define Hush__ComponentTraits__EComponentOpsFlags_HasCtor 1
#define Hush__ComponentTraits__EComponentOpsFlags_HasDtor 2
#define Hush__ComponentTraits__EComponentOpsFlags_HasCopy 4
#define Hush__ComponentTraits__EComponentOpsFlags_HasMove 8
#define Hush__ComponentTraits__EComponentOpsFlags_HasCopyCtor 16
#define Hush__ComponentTraits__EComponentOpsFlags_HasMoveCtor 32
#define Hush__ComponentTraits__EComponentOpsFlags_HasMoveDtor 64
#define Hush__ComponentTraits__EComponentOpsFlags_HasMoveAssignDtor 128
#define Hush__ComponentTraits__EComponentOpsFlags_NoCtor 1024
#define Hush__ComponentTraits__EComponentOpsFlags_NoDtor 4096
#define Hush__ComponentTraits__EComponentOpsFlags_NoCopy 8192
#define Hush__ComponentTraits__EComponentOpsFlags_NoMove 16384
#define Hush__ComponentTraits__EComponentOpsFlags_NoCopyCtor 32768
#define Hush__ComponentTraits__EComponentOpsFlags_NoMoveCtor 65536
#define Hush__ComponentTraits__EComponentOpsFlags_NoMoveDtor 131072
#define Hush__ComponentTraits__EComponentOpsFlags_NoMoveAssignDtor 262144

typedef enum Hush__RawQuery__ECacheMode {
	Hush__RawQuery__ECacheMode_Default = 0,
	Hush__RawQuery__ECacheMode_Auto = 1,
	Hush__RawQuery__ECacheMode_All = 2,
	Hush__RawQuery__ECacheMode_None = 3,
} Hush__RawQuery__ECacheMode;

typedef enum Hush__RawQuery__EComponentAccess {
	Hush__RawQuery__EComponentAccess_ReadOnly = 0,
	Hush__RawQuery__EComponentAccess_WriteOnly = 1,
	Hush__RawQuery__EComponentAccess_ReadWrite = 2,
	Hush__RawQuery__EComponentAccess_Default = 2,
} Hush__RawQuery__EComponentAccess;

typedef enum Hush__EComponentObserverType {
	Hush__EComponentObserverType_Add = 0,
	Hush__EComponentObserverType_Remove = 1,
	Hush__EComponentObserverType_Set = 2,
} Hush__EComponentObserverType;

typedef enum Hush__HushEngine__EError {
	Hush__HushEngine__EError_None = 0,
	Hush__HushEngine__EError_InvalidScene = 1,
} Hush__HushEngine__EError;

typedef enum Hush__EKeyCode {
	Hush__EKeyCode_UNKNOWN = 0,
	Hush__EKeyCode_A = 4,
	Hush__EKeyCode_B = 5,
	Hush__EKeyCode_C = 6,
	Hush__EKeyCode_D = 7,
	Hush__EKeyCode_E = 8,
	Hush__EKeyCode_F = 9,
	Hush__EKeyCode_G = 10,
	Hush__EKeyCode_H = 11,
	Hush__EKeyCode_I = 12,
	Hush__EKeyCode_J = 13,
	Hush__EKeyCode_K = 14,
	Hush__EKeyCode_L = 15,
	Hush__EKeyCode_M = 16,
	Hush__EKeyCode_N = 17,
	Hush__EKeyCode_O = 18,
	Hush__EKeyCode_P = 19,
	Hush__EKeyCode_Q = 20,
	Hush__EKeyCode_R = 21,
	Hush__EKeyCode_S = 22,
	Hush__EKeyCode_T = 23,
	Hush__EKeyCode_U = 24,
	Hush__EKeyCode_V = 25,
	Hush__EKeyCode_W = 26,
	Hush__EKeyCode_X = 27,
	Hush__EKeyCode_Y = 28,
	Hush__EKeyCode_Z = 29,
	Hush__EKeyCode_Num1 = 30,
	Hush__EKeyCode_Num2 = 31,
	Hush__EKeyCode_Num3 = 32,
	Hush__EKeyCode_Num4 = 33,
	Hush__EKeyCode_Num5 = 34,
	Hush__EKeyCode_Num6 = 35,
	Hush__EKeyCode_Num7 = 36,
	Hush__EKeyCode_Num8 = 37,
	Hush__EKeyCode_Num9 = 38,
	Hush__EKeyCode_Num0 = 39,
	Hush__EKeyCode_RETURN = 40,
	Hush__EKeyCode_ESCAPE = 41,
	Hush__EKeyCode_BACKSPACE = 42,
	Hush__EKeyCode_TAB = 43,
	Hush__EKeyCode_SPACE = 44,
	Hush__EKeyCode_MINUS = 45,
	Hush__EKeyCode_EQUALS = 46,
	Hush__EKeyCode_LEFTBRACKET = 47,
	Hush__EKeyCode_RIGHTBRACKET = 48,
	Hush__EKeyCode_BACKSLASH = 49,
	Hush__EKeyCode_NONUSHASH = 50,
	Hush__EKeyCode_SEMICOLON = 51,
	Hush__EKeyCode_APOSTROPHE = 52,
	Hush__EKeyCode_GRAVE = 53,
	Hush__EKeyCode_COMMA = 54,
	Hush__EKeyCode_PERIOD = 55,
	Hush__EKeyCode_SLASH = 56,
	Hush__EKeyCode_CAPSLOCK = 57,
	Hush__EKeyCode_F1 = 58,
	Hush__EKeyCode_F2 = 59,
	Hush__EKeyCode_F3 = 60,
	Hush__EKeyCode_F4 = 61,
	Hush__EKeyCode_F5 = 62,
	Hush__EKeyCode_F6 = 63,
	Hush__EKeyCode_F7 = 64,
	Hush__EKeyCode_F8 = 65,
	Hush__EKeyCode_F9 = 66,
	Hush__EKeyCode_F10 = 67,
	Hush__EKeyCode_F11 = 68,
	Hush__EKeyCode_F12 = 69,
	Hush__EKeyCode_PRINTSCREEN = 70,
	Hush__EKeyCode_SCROLLLOCK = 71,
	Hush__EKeyCode_PAUSE = 72,
	Hush__EKeyCode_INSERT = 73,
	Hush__EKeyCode_HOME = 74,
	Hush__EKeyCode_PAGEUP = 75,
	Hush__EKeyCode_DEL = 76,
	Hush__EKeyCode_END = 77,
	Hush__EKeyCode_PAGEDOWN = 78,
	Hush__EKeyCode_RIGHT = 79,
	Hush__EKeyCode_LEFT = 80,
	Hush__EKeyCode_DOWN = 81,
	Hush__EKeyCode_UP = 82,
	Hush__EKeyCode_NUMLOCKCLEAR = 83,
	Hush__EKeyCode_KpDivide = 84,
	Hush__EKeyCode_KpMultiply = 85,
	Hush__EKeyCode_KpMinus = 86,
	Hush__EKeyCode_KpPlus = 87,
	Hush__EKeyCode_KpEnter = 88,
	Hush__EKeyCode_Kp1 = 89,
	Hush__EKeyCode_Kp2 = 90,
	Hush__EKeyCode_Kp3 = 91,
	Hush__EKeyCode_Kp4 = 92,
	Hush__EKeyCode_Kp5 = 93,
	Hush__EKeyCode_Kp6 = 94,
	Hush__EKeyCode_Kp7 = 95,
	Hush__EKeyCode_Kp8 = 96,
	Hush__EKeyCode_Kp9 = 97,
	Hush__EKeyCode_Kp0 = 98,
	Hush__EKeyCode_KpPeriod = 99,
	Hush__EKeyCode_NONUSBACKSLASH = 100,
	Hush__EKeyCode_APPLICATION = 101,
	Hush__EKeyCode_POWER = 102,
	Hush__EKeyCode_KpEquals = 103,
	Hush__EKeyCode_F13 = 104,
	Hush__EKeyCode_F14 = 105,
	Hush__EKeyCode_F15 = 106,
	Hush__EKeyCode_F16 = 107,
	Hush__EKeyCode_F17 = 108,
	Hush__EKeyCode_F18 = 109,
	Hush__EKeyCode_F19 = 110,
	Hush__EKeyCode_F20 = 111,
	Hush__EKeyCode_F21 = 112,
	Hush__EKeyCode_F22 = 113,
	Hush__EKeyCode_F23 = 114,
	Hush__EKeyCode_F24 = 115,
	Hush__EKeyCode_EXECUTE = 116,
	Hush__EKeyCode_HELP = 117,
	Hush__EKeyCode_MENU = 118,
	Hush__EKeyCode_SELECT = 119,
	Hush__EKeyCode_STOP = 120,
	Hush__EKeyCode_AGAIN = 121,
	Hush__EKeyCode_UNDO = 122,
	Hush__EKeyCode_CUT = 123,
	Hush__EKeyCode_COPY = 124,
	Hush__EKeyCode_PASTE = 125,
	Hush__EKeyCode_FIND = 126,
	Hush__EKeyCode_MUTE = 127,
	Hush__EKeyCode_VOLUMEUP = 128,
	Hush__EKeyCode_VOLUMEDOWN = 129,
	Hush__EKeyCode_KpComma = 133,
	Hush__EKeyCode_KpEqualsaS400 = 134,
	Hush__EKeyCode_INTERNATIONAL1 = 135,
	Hush__EKeyCode_INTERNATIONAL2 = 136,
	Hush__EKeyCode_INTERNATIONAL3 = 137,
	Hush__EKeyCode_INTERNATIONAL4 = 138,
	Hush__EKeyCode_INTERNATIONAL5 = 139,
	Hush__EKeyCode_INTERNATIONAL6 = 140,
	Hush__EKeyCode_INTERNATIONAL7 = 141,
	Hush__EKeyCode_INTERNATIONAL8 = 142,
	Hush__EKeyCode_INTERNATIONAL9 = 143,
	Hush__EKeyCode_LANG1 = 144,
	Hush__EKeyCode_LANG2 = 145,
	Hush__EKeyCode_LANG3 = 146,
	Hush__EKeyCode_LANG4 = 147,
	Hush__EKeyCode_LANG5 = 148,
	Hush__EKeyCode_LANG6 = 149,
	Hush__EKeyCode_LANG7 = 150,
	Hush__EKeyCode_LANG8 = 151,
	Hush__EKeyCode_LANG9 = 152,
	Hush__EKeyCode_ALTERASE = 153,
	Hush__EKeyCode_SYSREQ = 154,
	Hush__EKeyCode_CANCEL = 155,
	Hush__EKeyCode_CLEAR = 156,
	Hush__EKeyCode_PRIOR = 157,
	Hush__EKeyCode_RETURN2 = 158,
	Hush__EKeyCode_SEPARATOR = 159,
	Hush__EKeyCode_OUTKEY = 160,
	Hush__EKeyCode_OPER = 161,
	Hush__EKeyCode_CLEARAGAIN = 162,
	Hush__EKeyCode_CRSEL = 163,
	Hush__EKeyCode_EXSEL = 164,
	Hush__EKeyCode_Kp00 = 176,
	Hush__EKeyCode_Kp000 = 177,
	Hush__EKeyCode_THOUSANDSSEPARATOR = 178,
	Hush__EKeyCode_DECIMALSEPARATOR = 179,
	Hush__EKeyCode_CURRENCYUNIT = 180,
	Hush__EKeyCode_CURRENCYSUBUNIT = 181,
	Hush__EKeyCode_KpLeftparen = 182,
	Hush__EKeyCode_KpRightparen = 183,
	Hush__EKeyCode_KpLeftbrace = 184,
	Hush__EKeyCode_KpRightbrace = 185,
	Hush__EKeyCode_KpTab = 186,
	Hush__EKeyCode_KpBackspace = 187,
	Hush__EKeyCode_KpA = 188,
	Hush__EKeyCode_KpB = 189,
	Hush__EKeyCode_KpC = 190,
	Hush__EKeyCode_KpD = 191,
	Hush__EKeyCode_KpE = 192,
	Hush__EKeyCode_KpF = 193,
	Hush__EKeyCode_KpXor = 194,
	Hush__EKeyCode_KpPower = 195,
	Hush__EKeyCode_KpPercent = 196,
	Hush__EKeyCode_KpLess = 197,
	Hush__EKeyCode_KpGreater = 198,
	Hush__EKeyCode_KpAmpersand = 199,
	Hush__EKeyCode_KpDblampersand = 200,
	Hush__EKeyCode_KpVerticalbar = 201,
	Hush__EKeyCode_KpDblverticalbar = 202,
	Hush__EKeyCode_KpColon = 203,
	Hush__EKeyCode_KpHash = 204,
	Hush__EKeyCode_KpSpace = 205,
	Hush__EKeyCode_KpAt = 206,
	Hush__EKeyCode_KpExclam = 207,
	Hush__EKeyCode_KpMemstore = 208,
	Hush__EKeyCode_KpMemrecall = 209,
	Hush__EKeyCode_KpMemclear = 210,
	Hush__EKeyCode_KpMemadd = 211,
	Hush__EKeyCode_KpMemsubtract = 212,
	Hush__EKeyCode_KpMemmultiply = 213,
	Hush__EKeyCode_KpMemdivide = 214,
	Hush__EKeyCode_KpPlusminus = 215,
	Hush__EKeyCode_KpClear = 216,
	Hush__EKeyCode_KpClearentry = 217,
	Hush__EKeyCode_KpBinary = 218,
	Hush__EKeyCode_KpOctal = 219,
	Hush__EKeyCode_KpDecimal = 220,
	Hush__EKeyCode_KpHexadecimal = 221,
	Hush__EKeyCode_LCtrl = 224,
	Hush__EKeyCode_LShift = 225,
	Hush__EKeyCode_LAlt = 226,
	Hush__EKeyCode_LGui = 227,
	Hush__EKeyCode_RCtrl = 228,
	Hush__EKeyCode_RShift = 229,
	Hush__EKeyCode_RAlt = 230,
	Hush__EKeyCode_RGui = 231,
	Hush__EKeyCode_MODE = 257,
	Hush__EKeyCode_AUDIONEXT = 258,
	Hush__EKeyCode_AUDIOPREV = 259,
	Hush__EKeyCode_AUDIOSTOP = 260,
	Hush__EKeyCode_AUDIOPLAY = 261,
	Hush__EKeyCode_AUDIOMUTE = 262,
	Hush__EKeyCode_MEDIASELECT = 263,
	Hush__EKeyCode_WWW = 264,
	Hush__EKeyCode_MAIL = 265,
	Hush__EKeyCode_CALCULATOR = 266,
	Hush__EKeyCode_COMPUTER = 267,
	Hush__EKeyCode_AcSearch = 268,
	Hush__EKeyCode_AcHome = 269,
	Hush__EKeyCode_AcBack = 270,
	Hush__EKeyCode_AcForward = 271,
	Hush__EKeyCode_AcStop = 272,
	Hush__EKeyCode_AcRefresh = 273,
	Hush__EKeyCode_AcBookmarks = 274,
	Hush__EKeyCode_BRIGHTNESSDOWN = 275,
	Hush__EKeyCode_BRIGHTNESSUP = 276,
	Hush__EKeyCode_DISPLAYSWITCH = 277,
	Hush__EKeyCode_KBDILLUMTOGGLE = 278,
	Hush__EKeyCode_KBDILLUMDOWN = 279,
	Hush__EKeyCode_KBDILLUMUP = 280,
	Hush__EKeyCode_EJECT = 281,
	Hush__EKeyCode_SLEEP = 282,
	Hush__EKeyCode_APP1 = 283,
	Hush__EKeyCode_APP2 = 284,
	Hush__EKeyCode_AUDIOREWIND = 285,
	Hush__EKeyCode_AUDIOFASTFORWARD = 286,
	Hush__EKeyCode_SOFTLEFT = 287,
	Hush__EKeyCode_SOFTRIGHT = 288,
	Hush__EKeyCode_CALL = 289,
	Hush__EKeyCode_ENDCALL = 290,
	Hush__EKeyCode_SdlNumScancodes = 512,
} Hush__EKeyCode;

typedef enum Hush__EKeyState {
	Hush__EKeyState_None = -1,
	Hush__EKeyState_Pressed = 0,
	Hush__EKeyState_Held = 1,
	Hush__EKeyState_Released = 2,
} Hush__EKeyState;

typedef enum Hush__EMouseButton {
	Hush__EMouseButton_Left = 1,
	Hush__EMouseButton_Middle = 2,
	Hush__EMouseButton_Right = 3,
	Hush__EMouseButton_X1 = 4,
	Hush__EMouseButton_X2 = 5,
} Hush__EMouseButton;

typedef enum Hush__ECursorLockMode {
	Hush__ECursorLockMode_Free = 0,
	Hush__ECursorLockMode_Locked = 1,
} Hush__ECursorLockMode;

typedef struct Vector2 {
	float x;
	float y;
} Vector2;

typedef struct Vector3 {
	float x;
	float y;
	float z;
} Vector3;

typedef struct Vector4 {
	float x;
	float y;
	float z;
	float w;
} Vector4;

typedef struct DVector2 {
	double x;
	double y;
} DVector2;

typedef struct DVector3 {
	double x;
	double y;
	double z;
} DVector3;

typedef struct DVector4 {
	double x;
	double y;
	double z;
	double w;
} DVector4;

typedef struct U8Vector2 {
	uint8_t x;
	uint8_t y;
} U8Vector2;

typedef struct I8Vector2 {
	int8_t x;
	int8_t y;
} I8Vector2;

typedef struct U8Vector3 {
	uint8_t x;
	uint8_t y;
	uint8_t z;
} U8Vector3;

typedef struct I8Vector3 {
	int8_t x;
	int8_t y;
	int8_t z;
} I8Vector3;

typedef struct U8Vector4 {
	uint8_t x;
	uint8_t y;
	uint8_t z;
	uint8_t w;
} U8Vector4;

typedef struct I8Vector4 {
	int8_t x;
	int8_t y;
	int8_t z;
	int8_t w;
} I8Vector4;

typedef struct U16Vector2 {
	uint16_t x;
	uint16_t y;
} U16Vector2;

typedef struct I16Vector2 {
	int16_t x;
	int16_t y;
} I16Vector2;

typedef struct U16Vector3 {
	uint16_t x;
	uint16_t y;
	uint16_t z;
} U16Vector3;

typedef struct I16Vector3 {
	int16_t x;
	int16_t y;
	int16_t z;
} I16Vector3;

typedef struct U16Vector4 {
	uint16_t x;
	uint16_t y;
	uint16_t z;
	uint16_t w;
} U16Vector4;

typedef struct I16Vector4 {
	int16_t x;
	int16_t y;
	int16_t z;
	int16_t w;
} I16Vector4;

typedef struct U32Vector2 {
	uint32_t x;
	uint32_t y;
} U32Vector2;

typedef struct I32Vector2 {
	int32_t x;
	int32_t y;
} I32Vector2;

typedef struct U32Vector3 {
	uint32_t x;
	uint32_t y;
	uint32_t z;
} U32Vector3;

typedef struct I32Vector3 {
	int32_t x;
	int32_t y;
	int32_t z;
} I32Vector3;

typedef struct U32Vector4 {
	uint32_t x;
	uint32_t y;
	uint32_t z;
	uint32_t w;
} U32Vector4;

typedef struct I32Vector4 {
	int32_t x;
	int32_t y;
	int32_t z;
	int32_t w;
} I32Vector4;

typedef struct U64Vector2 {
	uint64_t x;
	uint64_t y;
} U64Vector2;

typedef struct I64Vector2 {
	int64_t x;
	int64_t y;
} I64Vector2;

typedef struct U64Vector3 {
	uint64_t x;
	uint64_t y;
	uint64_t z;
} U64Vector3;

typedef struct I64Vector3 {
	int64_t x;
	int64_t y;
	int64_t z;
} I64Vector3;

typedef struct U64Vector4 {
	uint64_t x;
	uint64_t y;
	uint64_t z;
	uint64_t w;
} U64Vector4;

typedef struct I64Vector4 {
	int64_t x;
	int64_t y;
	int64_t z;
	int64_t w;
} I64Vector4;

typedef struct Matrix2 {
	float m[2];
} Matrix2;

typedef struct Matrix3 {
	float m[3];
} Matrix3;

typedef struct Matrix4 {
	float m[4];
} Matrix4;

typedef struct DMatrix2 {
	double m[2];
} DMatrix2;

typedef struct DMatrix3 {
	double m[3];
} DMatrix3;

typedef struct DMatrix4 {
	double m[4];
} DMatrix4;

typedef struct Quat {
	float x;
	float y;
	float z;
	float w;
} Quat;

typedef struct Hush__ComponentTraits__ComponentOps {
	void (*ctor)(void *, int32_t, const void *);
	void (*dtor)(void *, int32_t, const void *);
	void (*copy)(void *, const void *, int32_t, const void *);
	void (*move)(void *, void *, int32_t, const void *);
	void (*copyCtor)(void *, const void *, int32_t, const void *);
	void (*moveCtor)(void *, void *, int32_t, const void *);
	void (*moveDtor)(void *, void *, int32_t, const void *);
	void (*moveAssignDtor)(void *, void *, int32_t, const void *);
} Hush__ComponentTraits__ComponentOps;

typedef struct Hush__ComponentTraits__ComponentInfo {
	size_t size;
	size_t alignment;
	const char * name;
	Hush__ComponentTraits__ComponentOps ops;
	Hush__ComponentTraits__EComponentOpsFlags opsFlags;
	void * userCtx;
	void (*userCtxFree)(void *);
} Hush__ComponentTraits__ComponentInfo;

typedef struct Hush__Entity {
	alignas(8) char m_member0[8];
	alignas(8) char m_member1[8];
} Hush__Entity;

void Hush__Entity_destroy(Hush__Entity **self);
typedef struct Hush__RawQuery {
	alignas(8) char m_member0[8];
	alignas(8) char m_member1[8];
} Hush__RawQuery;

void Hush__RawQuery_destroy(Hush__RawQuery **self);
typedef struct Hush__RawQuery__QueryIterator {
	alignas(1) char m_member0[384];
	alignas(8) char m_member1[8];
	alignas(1) char m_member2[1];
} Hush__RawQuery__QueryIterator;

void Hush__RawQuery__QueryIterator_destroy(Hush__RawQuery__QueryIterator **self);
typedef struct Hush__OpaqueQueryDescriptor {
	alignas(1) char m_member0[2440];
} Hush__OpaqueQueryDescriptor;

void Hush__OpaqueQueryDescriptor_destroy(Hush__OpaqueQueryDescriptor **self);
typedef struct Hush__Scene Hush__Scene;
typedef struct Hush__HushEngine Hush__HushEngine;
typedef struct Hush__Transform {
	alignas(4) char m_member0[64];
	alignas(4) char m_member1[12];
	alignas(4) char m_member2[16];
	alignas(1) char m_member3[1];
} Hush__Transform;

void Hush__Transform_destroy(Hush__Transform **self);
typedef struct Hush__RenderingSystemAPI {
	Hush__Entity_EntityId (*instantiateMeshEntities)(const char *, void *);
	void * instance;
} Hush__RenderingSystemAPI;

extern Hush__Entity_EntityId Hush__Entity__RegisterComponentRaw(Hush__Entity *self, const Hush__ComponentTraits__ComponentInfo * desc);
extern void * Hush__Entity__AddComponentRaw(Hush__Entity *self, Hush__Entity_EntityId componentId);
extern void * Hush__Entity__GetComponentRaw(Hush__Entity *self, Hush__Entity_EntityId componentId);
extern const void * Hush__Entity__GetComponentConstRaw(Hush__Entity *self, Hush__Entity_EntityId componentId);
extern bool Hush__Entity__HasComponentRaw(Hush__Entity *self, Hush__Entity_EntityId componentId);
extern void * Hush__Entity__EmplaceComponentRaw(Hush__Entity *self, Hush__Entity_EntityId componentId, size_t componentSize, bool * isNew);
extern bool Hush__Entity__RemoveComponentRaw(Hush__Entity *self, Hush__Entity_EntityId componentId);
extern void Hush__Entity__SetComponentActiveRaw(Hush__Entity *self, Hush__Entity_EntityId componentId, bool active);
extern void Hush__Entity__AddChild(Hush__Entity *self, const Hush__Entity * child);
extern int32_t Hush__Entity__GetChildCount(Hush__Entity *self);
extern void Hush__Entity__AddRelationship(Hush__Entity *self, const Hush__Entity * relationship, const Hush__Entity * target);
extern Hush__Entity_EntityId Hush__Entity__GetId(Hush__Entity *self);
extern bool Hush__Entity__IsAlive(Hush__Entity *self);
extern bool Hush__RawQuery__QueryIterator__Next(Hush__RawQuery__QueryIterator *self);
extern void Hush__RawQuery__QueryIterator__Skip(Hush__RawQuery__QueryIterator *self);
extern bool Hush__RawQuery__QueryIterator__Finished(Hush__RawQuery__QueryIterator *self);
extern size_t Hush__RawQuery__QueryIterator__Size(Hush__RawQuery__QueryIterator *self);
extern void * Hush__RawQuery__QueryIterator__GetComponentAt(Hush__RawQuery__QueryIterator *self, int8_t index, size_t size);
extern uint64_t Hush__RawQuery__QueryIterator__GetEntityAt(Hush__RawQuery__QueryIterator *self, size_t index);
extern Hush__Scene * Hush__RawQuery__GetScene(Hush__RawQuery *self);
extern Hush__RawQuery__QueryIterator Hush__RawQuery__GetIterator(Hush__RawQuery *self);
extern void Hush__impl__QueryBuilderImpl__WithRelationship(uint8_t * queryDesc, uint8_t * termCountRef, const Hush__Entity * relationship);
extern void Hush__impl__QueryBuilderImpl__WithTerm(uint8_t * queryDesc, uint8_t * termCountRef, Hush__Entity_EntityId term);
extern void Hush__impl__QueryBuilderImpl__InitDescriptor(uint8_t * queryDesc, Hush__Entity_EntityId *componentsData, const size_t componentsSize);
extern void Hush__impl__QueryBuilderImpl__Without(uint8_t * queryDesc, uint8_t * termCountRef, Hush__Entity_EntityId term);
extern void Hush__impl__QueryBuilderImpl__WithOptional(uint8_t * queryDesc, uint8_t * termCountRef, Hush__Entity_EntityId term);
extern Hush__RawQuery Hush__impl__QueryBuilderImpl__InitQuery(Hush__Scene * scene, const uint8_t * queryDesc);
extern uint8_t * Hush__OpaqueQueryDescriptor__data(Hush__OpaqueQueryDescriptor *self);
extern void Hush__Scene__RemoveSystem(Hush__Scene *self, char *nameData, const size_t nameSize);
extern Hush__Entity Hush__Scene__CreateEntity(Hush__Scene *self);
extern Hush__Entity Hush__Scene__CreateEntityWithName(Hush__Scene *self, char *nameData, const size_t nameSize);
extern Hush__Entity Hush__Scene__CreateEntityWithKey(Hush__Scene *self, char *keyData, const size_t keySize);
extern void Hush__Scene__AddComponentObserverRaw(Hush__Scene *self, Hush__Entity_EntityId componentId, size_t componentSize, Hush__EComponentObserverType observerType, Hush__ObserverCallback_t callback);
extern void Hush__Scene__DestroyEntity(Hush__Scene *self, Hush__Entity * entity);
extern Hush__Entity Hush__Scene__EntityFromIdUnchecked(Hush__Scene *self, Hush__Entity_EntityId id);
extern Hush__Entity_EntityId Hush__Scene__RegisterComponentRaw(Hush__Scene *self, const Hush__ComponentTraits__ComponentInfo * desc);
extern void Hush__Scene__MarkComponentToggleableRaw(Hush__Scene *self, Hush__Entity_EntityId id);
extern Hush__Entity_EntityId Hush__Scene__Lookup(Hush__Scene *self, char *tagData, const size_t tagSize);
extern Hush__RawQuery Hush__Scene__CreateRawQuery(Hush__Scene *self, Hush__Entity_EntityId *componentsData, const size_t componentsSize, Hush__RawQuery__ECacheMode cacheMode);
extern Hush__Scene * Hush__HushEngine__GetScene(Hush__HushEngine *self);
extern Hush__HushEngine__EError Hush__HushEngine__LoadScene(Hush__HushEngine *self, Hush__Scene * scene);
extern void Hush__Transform__SetPosition(Hush__Transform *self, Vector3 position);
extern Vector3 * Hush__Transform__GetPosition(Hush__Transform *self);
extern Vector3 Hush__Transform__GetPositionValue(Hush__Transform *self);
extern void Hush__Transform__SetScale(Hush__Transform *self, Vector3 scale);
extern void Hush__Transform__SetEulerAngles(Hush__Transform *self, const Vector3 * euler);
extern Vector3 Hush__Transform__GetEulerAngles(Hush__Transform *self);
extern Vector3 Hush__Transform__Forward(Hush__Transform *self);
extern Vector3 Hush__Transform__Up(Hush__Transform *self);
extern Vector3 Hush__Transform__Right(Hush__Transform *self);
extern bool Hush__InputManager__IsKeyDown(Hush__EKeyCode key);
extern bool Hush__InputManager__IsKeyDownThisFrame(Hush__EKeyCode key);
extern bool Hush__InputManager__IsKeyUp(Hush__EKeyCode key);
extern bool Hush__InputManager__IsKeyHeld(Hush__EKeyCode key);
extern bool Hush__InputManager__GetMouseButtonPressed(Hush__EMouseButton button);
extern bool Hush__InputManager__FetchCharThisFrame(char * outChar);
extern Vector2 Hush__InputManager__GetMousePosition(void);
extern Vector2 Hush__InputManager__GetMouseAcceleration(void);
extern void Hush__InputManager__SetCursorLock(Hush__ECursorLockMode lockMode);
typedef struct HushFuncPtrTable {
	Hush__Entity_EntityId (*HushFuncPtr_Hush__Entity__RegisterComponentRaw)(Hush__Entity *self, const Hush__ComponentTraits__ComponentInfo *);
	void * (*HushFuncPtr_Hush__Entity__AddComponentRaw)(Hush__Entity *self, Hush__Entity_EntityId);
	void * (*HushFuncPtr_Hush__Entity__GetComponentRaw)(Hush__Entity *self, Hush__Entity_EntityId);
	const void * (*HushFuncPtr_Hush__Entity__GetComponentConstRaw)(Hush__Entity *self, Hush__Entity_EntityId);
	bool (*HushFuncPtr_Hush__Entity__HasComponentRaw)(Hush__Entity *self, Hush__Entity_EntityId);
	void * (*HushFuncPtr_Hush__Entity__EmplaceComponentRaw)(Hush__Entity *self, Hush__Entity_EntityId, size_t, bool *);
	bool (*HushFuncPtr_Hush__Entity__RemoveComponentRaw)(Hush__Entity *self, Hush__Entity_EntityId);
	void (*HushFuncPtr_Hush__Entity__SetComponentActiveRaw)(Hush__Entity *self, Hush__Entity_EntityId, bool);
	void (*HushFuncPtr_Hush__Entity__AddChild)(Hush__Entity *self, const Hush__Entity *);
	int32_t (*HushFuncPtr_Hush__Entity__GetChildCount)(Hush__Entity *self);
	void (*HushFuncPtr_Hush__Entity__AddRelationship)(Hush__Entity *self, const Hush__Entity *, const Hush__Entity *);
	Hush__Entity_EntityId (*HushFuncPtr_Hush__Entity__GetId)(Hush__Entity *self);
	bool (*HushFuncPtr_Hush__Entity__IsAlive)(Hush__Entity *self);
	bool (*HushFuncPtr_Hush__RawQuery__QueryIterator__Next)(Hush__RawQuery__QueryIterator *self);
	void (*HushFuncPtr_Hush__RawQuery__QueryIterator__Skip)(Hush__RawQuery__QueryIterator *self);
	bool (*HushFuncPtr_Hush__RawQuery__QueryIterator__Finished)(Hush__RawQuery__QueryIterator *self);
	size_t (*HushFuncPtr_Hush__RawQuery__QueryIterator__Size)(Hush__RawQuery__QueryIterator *self);
	void * (*HushFuncPtr_Hush__RawQuery__QueryIterator__GetComponentAt)(Hush__RawQuery__QueryIterator *self, int8_t, size_t);
	uint64_t (*HushFuncPtr_Hush__RawQuery__QueryIterator__GetEntityAt)(Hush__RawQuery__QueryIterator *self, size_t);
	Hush__Scene * (*HushFuncPtr_Hush__RawQuery__GetScene)(Hush__RawQuery *self);
	Hush__RawQuery__QueryIterator (*HushFuncPtr_Hush__RawQuery__GetIterator)(Hush__RawQuery *self);
	void (*HushFuncPtr_Hush__impl__QueryBuilderImpl__WithRelationship)(uint8_t *, uint8_t *, const Hush__Entity *);
	void (*HushFuncPtr_Hush__impl__QueryBuilderImpl__WithTerm)(uint8_t *, uint8_t *, Hush__Entity_EntityId);
	void (*HushFuncPtr_Hush__impl__QueryBuilderImpl__InitDescriptor)(uint8_t *, Hush__Entity_EntityId*, const size_t componentsSize);
	void (*HushFuncPtr_Hush__impl__QueryBuilderImpl__Without)(uint8_t *, uint8_t *, Hush__Entity_EntityId);
	void (*HushFuncPtr_Hush__impl__QueryBuilderImpl__WithOptional)(uint8_t *, uint8_t *, Hush__Entity_EntityId);
	Hush__RawQuery (*HushFuncPtr_Hush__impl__QueryBuilderImpl__InitQuery)(Hush__Scene *, const uint8_t *);
	uint8_t * (*HushFuncPtr_Hush__OpaqueQueryDescriptor__data)(Hush__OpaqueQueryDescriptor *self);
	void (*HushFuncPtr_Hush__Scene__RemoveSystem)(Hush__Scene *self, char*, const size_t nameSize);
	Hush__Entity (*HushFuncPtr_Hush__Scene__CreateEntity)(Hush__Scene *self);
	Hush__Entity (*HushFuncPtr_Hush__Scene__CreateEntityWithName)(Hush__Scene *self, char*, const size_t nameSize);
	Hush__Entity (*HushFuncPtr_Hush__Scene__CreateEntityWithKey)(Hush__Scene *self, char*, const size_t keySize);
	void (*HushFuncPtr_Hush__Scene__AddComponentObserverRaw)(Hush__Scene *self, Hush__Entity_EntityId, size_t, Hush__EComponentObserverType, Hush__ObserverCallback_t);
	void (*HushFuncPtr_Hush__Scene__DestroyEntity)(Hush__Scene *self, Hush__Entity *);
	Hush__Entity (*HushFuncPtr_Hush__Scene__EntityFromIdUnchecked)(Hush__Scene *self, Hush__Entity_EntityId);
	Hush__Entity_EntityId (*HushFuncPtr_Hush__Scene__RegisterComponentRaw)(Hush__Scene *self, const Hush__ComponentTraits__ComponentInfo *);
	void (*HushFuncPtr_Hush__Scene__MarkComponentToggleableRaw)(Hush__Scene *self, Hush__Entity_EntityId);
	Hush__Entity_EntityId (*HushFuncPtr_Hush__Scene__Lookup)(Hush__Scene *self, char*, const size_t tagSize);
	Hush__RawQuery (*HushFuncPtr_Hush__Scene__CreateRawQuery)(Hush__Scene *self, Hush__Entity_EntityId*, const size_t componentsSize, Hush__RawQuery__ECacheMode);
	Hush__Scene * (*HushFuncPtr_Hush__HushEngine__GetScene)(Hush__HushEngine *self);
	Hush__HushEngine__EError (*HushFuncPtr_Hush__HushEngine__LoadScene)(Hush__HushEngine *self, Hush__Scene *);
	void (*HushFuncPtr_Hush__Transform__SetPosition)(Hush__Transform *self, Vector3);
	Vector3 * (*HushFuncPtr_Hush__Transform__GetPosition)(Hush__Transform *self);
	Vector3 (*HushFuncPtr_Hush__Transform__GetPositionValue)(Hush__Transform *self);
	void (*HushFuncPtr_Hush__Transform__SetScale)(Hush__Transform *self, Vector3);
	void (*HushFuncPtr_Hush__Transform__SetEulerAngles)(Hush__Transform *self, const Vector3 *);
	Vector3 (*HushFuncPtr_Hush__Transform__GetEulerAngles)(Hush__Transform *self);
	Vector3 (*HushFuncPtr_Hush__Transform__Forward)(Hush__Transform *self);
	Vector3 (*HushFuncPtr_Hush__Transform__Up)(Hush__Transform *self);
	Vector3 (*HushFuncPtr_Hush__Transform__Right)(Hush__Transform *self);
	bool (*HushFuncPtr_Hush__InputManager__IsKeyDown)(Hush__EKeyCode);
	bool (*HushFuncPtr_Hush__InputManager__IsKeyDownThisFrame)(Hush__EKeyCode);
	bool (*HushFuncPtr_Hush__InputManager__IsKeyUp)(Hush__EKeyCode);
	bool (*HushFuncPtr_Hush__InputManager__IsKeyHeld)(Hush__EKeyCode);
	bool (*HushFuncPtr_Hush__InputManager__GetMouseButtonPressed)(Hush__EMouseButton);
	bool (*HushFuncPtr_Hush__InputManager__FetchCharThisFrame)(char *);
	Vector2 (*HushFuncPtr_Hush__InputManager__GetMousePosition)(void);
	Vector2 (*HushFuncPtr_Hush__InputManager__GetMouseAcceleration)(void);
	void (*HushFuncPtr_Hush__InputManager__SetCursorLock)(Hush__ECursorLockMode);

} HushFuncPtrTable;

#ifdef HUSH_STATIC_BINDING
extern HushFuncPtrTable HUSH_FUNCPTR_TABLE;
#endif

#ifdef __cplusplus
}
#endif
// NOLINTEND
