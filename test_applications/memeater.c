// A simple memory-consuming program.
// Designed for testing out the meminfo sampler.

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
    int *temp = NULL;
    for (int count = 0;; count+=1000000)
    {
        //sleep(1);
        int size = ((6144 * 6144) + count) * sizeof(int);
        temp = (int *)realloc(temp, size);
        if (!temp)
        {
            break;
        }
        else
        {
            //printf("Allocated %d bytes\n", size);
            for (size_t i = 0; i < count; i++)
            {
                temp[i] = i;
            }
        }
    }
    sleep(5);
    free(temp);
    return 0;
}