//==========================================================================
/**
 *  @file    smartptr.h
 *  @brief  The header file of SmartPtr class.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================

#ifndef SMARTPTR_H
#define SMARTPTR_H

template <class T>
class SmartPtr
{
public:
    SmartPtr();
    SmartPtr(const SmartPtr&);
    SmartPtr& operator =(const SmartPtr&);
    T* operator ->();
    T* getPtr();
    ~SmartPtr();

private:
    T *p;
};

template <class T>
T* SmartPtr<T>::operator ->()
{
    return p;
}

template <class T>
SmartPtr<T>::SmartPtr()
    : p(new T())
{

}

template <class T>
SmartPtr<T>::SmartPtr(const SmartPtr& t)
{
    this->p = t.p;
    this->p->add_reference();
}

template <class T>
SmartPtr<T>& SmartPtr<T>::operator =(const SmartPtr<T>& t)
{
    if(this != &t)
    {
        if(this->p->release_reference() == 0)
            delete this->p;

        this->p = t.p;
        this->p->add_reference();
    }

    return *this;
}

template <class T>
T* SmartPtr<T>::getPtr()
{
    return this->p;
}

template <class T>
SmartPtr<T>::~SmartPtr()
{
    if(this->p->release_reference() == 0)
        delete p;
}

#endif // SMARTPTR_H
