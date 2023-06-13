//<license>
/*
   This file is part of Behmeth.
   Author: Behram Kapadia, wiowou@hotmail.com

    Behmeth is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Behmeth is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Behmeth.  If not, see <http://www.gnu.org/licenses/>.
*/

//</license>

#ifndef _BSTD_ARRAY_h
#define _BSTD_ARRAY_h

namespace bstd{

#ifdef MYDEBUG
  class ArrayTest;
#endif //MYDEBUG

//! A dynamically allocated mult-dimensional array class.

template<typename T, unsigned long long m_dim1, unsigned long long m_dim2=1, unsigned long long m_dim3=1, unsigned long long m_dim4=1>
class Array
{
public:
  Array()
  {
    m_data = 0;
    m_a2 = 0;
    m_a3 = 0;
    m_a4 = 0;
    
    allocate();
  }
  
  //! copy constructor
  Array( const Array &other )
  {
    allocate();
    assign(other.m_data);
  }
  
  //! assignment operator
  Array& operator=( Array other )
  {
    swap(other);
    return *this;
  }
  
  void swap( Array &other )
  {
    T*  tmp_data = other.m_data;
    T**  tmp_a2 = other.m_a2;
    T***  tmp_a3 = other.m_a3;
    T****  tmp_a4 = other.m_a4;
    
    other.m_data = m_data;
    other.m_a2 = m_a2;
    other.m_a3 = m_a3;
    other.m_a4 = m_a4;
    
    m_data = tmp_data;
    m_a2 = tmp_a2;
    m_a3 = tmp_a3;
    m_a4 = tmp_a4;
  }
  
  T* data()
  {
    return m_data;
  }
  
  void assign(T* data)
  {
    for ( unsigned long long i = 0; i < m_size; ++i )
    {
      m_data[i] = data[i];
    }
  }
  
  unsigned long long size()
  {
    return m_size;
  }
  
  T& operator[] (unsigned long long idx)
  {
    return m_data[idx];
  }
  
  ~Array()
  {
    destroy();
  }

protected:
  void destroy()
  {
    delete[] m_data;
    delete[] m_a2;
    delete[] m_a3;
    delete[] m_a4;
  }
  
  void allocate()
  {
    m_size = m_dim1 * m_dim2 * m_dim3 * m_dim4;
    m_data = new T[m_size];
    m_a2 = new T*[m_dim1 * m_dim2 * m_dim3];
    m_a3 = new T**[m_dim1 * m_dim2];
    m_a4 = new T***[m_dim1];
    
    unsigned long long dim[4];
    dim[0] = m_dim1;
    dim[1] = m_dim2;
    dim[2] = m_dim3;
    dim[3] = m_dim4;
    
    int maxD;
    for (maxD = 0; maxD < 4; ++maxD)
    {
      if (dim[maxD] == 1) break;
    }
    
    unsigned long long block = m_size;
    int n = maxD;
    
    --n;
    if (n > 0)
    {
      block /= dim[n];
      for (int i = 0; i < block; ++i)
      {
        m_a2[i] = &m_data[i*dim[n]];
      }
    }
    
    --n;
    if (n > 0)
    {
      block /= dim[n];
      for (int i = 0; i < block; ++i)
      {
        m_a3[i] = &m_a2[i*dim[n]];
      }
    }
    
    --n;
    if (n > 0)
    {
      block /= dim[n];
      for (int i = 0; i < block; ++i)
      {
        m_a4[i] = &m_a3[i*dim[n]];
      }
    }

  }

protected:
  T* m_data;
  
  T**    m_a2;
  T***   m_a3;
  T****  m_a4;
  
  unsigned long long m_size;
  
private:

};

template<typename T, unsigned long long m_dim1, unsigned long long m_dim2>
class Array2 : public Array<T,m_dim1,m_dim2>
{
public:
  T* operator[] (unsigned long long idx)
  {
    return Array<T,m_dim1,m_dim2>::m_a2[idx];
  }

protected:

private:

};

template<typename T, unsigned long long m_dim1, unsigned long long m_dim2, unsigned long long m_dim3>
class Array3 : public Array<T,m_dim1,m_dim2,m_dim3>
{
public:
  T** operator[] (unsigned long long idx)
  {
    return Array<T,m_dim1,m_dim2,m_dim3>::m_a3[idx];
  }

protected:

private:

};

template<typename T, unsigned long long m_dim1, unsigned long long m_dim2, unsigned long long m_dim3, unsigned long long m_dim4>
class Array4 : public Array<T,m_dim1,m_dim2,m_dim3,m_dim4>
{
public:
  T*** operator[] (unsigned long long idx)
  {
    return Array<T,m_dim1,m_dim2,m_dim3,m_dim4>::m_a4[idx];
  }

protected:

private:

};

}/*bstd*/ 

#endif /*_BSTD_ARRAY_h */

/*
The renal file now dynamically allocates memory for all arrays that have a dimension > 2. Each variable now only uses a total of 5*sizeof(float) space on the stack. All other memory is allocated dynamically on the heap. The memory is contiguous. This post explains why both the malloc and new command MUST allocate a logically contiguous block of memory upon a single call. http://stackoverflow.com/questions/3954188/how-malloc-works. If it did not, then pointer arithmetic into arrays would not work correctly and this would go against the specifications of the standard C language. Multiple calls do not have to allocate storage next to the previous call. There should be no more compilation problems due to limited stack space. I do not have a cuda compiler at home, so please make sure you include the array.h file in the same directory as the .cu file and compile as usual. Let me know if there are any compilation problems or if the code does not work as expected. I have tried my best to check the code I wrote by testing it on several smaller arrays, but I will need you to test and tell me if there is a problem that needs to be fixed. Please make sure that you use the C++ compiler. This code will not compile if you use the C compiler, because C does not support templates and classes. The C++ compiler command is usually:

CC

or

nvcc

for the nvidia c++ compiler.

The first file is Renal_new_bk.cu and the second is array.h. There is an #include "array.h" at the top of the .cu file, which brings in the code I wrote. The array.h file contains a c++ class to make dynamically allocated fixed dimension arrays where you can access elements the same way as with regular c arrays. In C, recall that multidimensional arrays are created this way:

float n1[NX][NY][NZ][19];
ptls[NX][NY][NZ];

With my array class, this syntax changes to:

bstd::Array4<float,NX,NY,NZ,19> n1;
bstd::Array3<float,NX,NY,NZ> ptls;

My code also supports 2D and 1D dynamic, fixed length arrays which have similar syntaxes.

Accessing elements is exactly the same in both cases:

ptls[i][j][k] = 1.0;

The class I wrote automatically allocates dynamic memory upon instantiation and frees the memory automatically when the variable goes out of scope. You don't need to do any memory allocation or freeing or any memory management of any kind. The only other difference is when using the cudaMemcpy command, my arrays need to be sent to the command like this:

cudaStatus = cudaMemcpy(D_n1, n1.data(), size_f * sizeof(float), cudaMemcpyHostToDevice);
cudaStatus = cudaMemcpy(n1.data(), D_n1, size_f * sizeof(float), cudaMemcpyDeviceToHost);

instead of what you previously had:

cudaStatus = cudaMemcpy(D_n1, n1, size_f * sizeof(float), cudaMemcpyHostToDevice);
cudaStatus = cudaMemcpy(n1, D_n1, size_f * sizeof(float), cudaMemcpyDeviceToHost);

In other words, you have to do n1.data(), not just n1.

I have made all necessary changes to the .cu file. To summarize, you only need to make minor changes to your existing code and you can change all of your arrays to dynamic memory arrays once you include the array.h file as a header.

I have introduced a couple of extra functions to make using the array simple.

QUICK TUTORIAL on array.h:

bstd::Array4<float,NX,NY,NZ,19> n1; //this instantiates the 4 dimensional n1 array of floats. Memory is automatically allocated on the heap in a continuous block.

if you want to use double precision instead of floats, all you have to do is replace the float with double.

bstd::Array4<double,NX,NY,NZ,19> n1;

int sizeOfn1 = n1.size(); //the .size() function returns the total size of n1, which is NX*NY*NZ*19 in this case.

float* p = n1.data(); //we now have a pointer to the block of continuous data stored in n1. Useful for memCpy commands copying from host to device.

p[i] = 5.0; //We can use 1D array syntax when accessing elements from p. i is in the range 0 < i < n1.size()

n1.data() = p; //Useful for memCpy commands when copying from device to host

n1.assign(p); //we can even replace the internal data with the data in p.

Now say we have another array, n2.

bstd::Array4<float,NX,NY,NZ,19> n2;

We can quickly swap the values from n1 to n2 by simply exchanging the internal pointers, which I do with the swap function:

n1.swap(n2);

n1 = n2; //this copies the data from n2 to n1 in one line of code.
*/
