#ifndef SMART_OBJECT_CUH
#define SMART_OBJECT_CUH
#include <cuda_runtime.h>
#include "../include/utils.cuh"

/*
Code to see the priority range of streams
int minPriority, maxPriority;
cudaDeviceGetStreamPriorityRange(&minPriority, &maxPriority);
std::cout << "minPriority: " << minPriority << std::endl;
std::cout << "maxPriority: " << maxPriority << std::endl;
*/
enum StreamPriority
{
    Low = 0,
    High = -5
};

template <typename T>
class smart_object
{
public:
    smart_object() : refCount(nullptr), object(nullptr) {}

    explicit smart_object(StreamPriority priority) : refCount(nullptr), object(nullptr) {}

    smart_object(const smart_object &other)
        : object(other.object), refCount(other.refCount)
    {
        IncrementRefCount();
    }

    smart_object &operator=(const smart_object &other)
    {
        if (this != &other)
        {
            DecrementRefCount();
            object = other.object;
            refCount = other.refCount;
            IncrementRefCount();
        }
        return *this;
    }

    ~smart_object()
    {
        DecrementRefCount();
    }

    T get() const
    {
        return object;
    }

    size_t getRefCount() const
    {
        return *refCount;
    }

private:
    T object;
    size_t *refCount;

    void IncrementRefCount()
    {
        if (refCount)
            ++(*refCount);
    }

    void DecrementRefCount() {}
};

template <>
smart_object<cudaStream_t>::smart_object();

template <>
smart_object<cudaStream_t>::smart_object(StreamPriority priority);

template <>
void smart_object<cudaEvent_t>::DecrementRefCount();

template <>
smart_object<cudaEvent_t>::smart_object();

template <>
void smart_object<cudaStream_t>::DecrementRefCount();

inline std::vector<smart_object<cudaStream_t>> streams;
inline std::vector<smart_object<cudaEvent_t>> events;

#endif