# coding=utf-8
import numpy as np
import scipy
from skimage.morphology import reconstruction, skeletonize
import os
import gdal
import scipy.ndimage
import skimage
from skimage import feature


## @brief imextendedmax Retorna la función "extended-maxima" de una imagen f, la cual es la
#    region maxima de la transformación "H-maxima". La region maxima contiene los componentes
#    conectados con el mismo valor de intensidad y cuyos bordes externos tienen un valor menor.
#
#
# @param		f	Imagen N x M(float-array)
# @param		h	Limite de altura (int)
#
# @return
#        emax Imagen resultado (float-array)
#
def imextendedmax(f,h):
    hmax = reconstruction(f-h,f,method='dilation')
    emax = hmax - reconstruction(hmax-1,hmax,method='dilation')
    return emax

## @brief imimposemin Modifica las intensidades de la imagen f mediante la reconstrucción morfológica,
#    limitando f a tener minimos locales donde mask sea uno. mask es una imagen binaria del mismo tamaño que f.
#
#
# @param		f	Imagen N x M (float-array)
# @param		mask	Imagen N x M (bool-array)
#
# @return
# @return		impomin	Imagen resultado N x M (float-array)
#
def imimposemin(f,mask):
    f += 1
    fm = np.ones(np.shape(f))*np.max(f)
    fm[mask.astype(np.bool)] = -np.inf
    msk = np.minimum(f,fm)
    impomin = reconstruction(fm, msk,method='erosion')
    return impomin

## @brief imregionalmax Retorna una imagen binaria que identifica las regiones maximas en f.
#  La region maxima contiene los componentes conectados con el mismo valor de intensidad
#  y cuyos bordes externos tienen un valor menor.
#
#
# @param		image	Imagen N x M (float-array)
# @param		ksize	Tamaño de ventana del filtro (int)
# @return
# @return		reg_max	Imagen resultado (bool-array)
#
def imregionalmax(image, ksize=10):
  filterkernel = np.ones((ksize, ksize))
  reg_max_loc = feature.peak_local_max(image,
                               footprint=filterkernel, indices=False,
                               exclude_border=0)
  return reg_max_loc.astype(np.uint8)

## @brief eliminatenoise retorna una imagen de etiquetas eliminando aquellas menores a 9 pixels.
#
#
# @param		Sp	Imagen de etiquetas N x M (int-array)
#
# @return
# @return		Sp	Imagen de etiquetas N x M (int-array)
#
def eliminatenoise(Sp):
    for i in np.unique(Sp):
        if np.sum(Sp[Sp==i]>0)<9:
            Sp[Sp==i]=0
    return Sp
## @brief HmaxCT retorna una imagen  de etiquetas, cada etiqueta representa un arbol y son etiquetados con numeros enteros
#         formados por pixeles.
#
#
# @param              dsm      Imagen de digital del modelo digital del terreno (float-array)
# @param              h        Valor Limite de altura (int)
# @param              poly     Imagen binaria de la region de interés (bool-array) 
# @param              resolution  Valor entre 0 y 1 que indica el porcentaje de resolución que se va a tomar de la imagen dsm (float).
#
# @return
# @return             Sp1      Imagen de etiquetas que contiene la posición de todos los pixeles etiquetados como arboles (int-array).
def HmaxCT(dsm,h,poly,resolution):
    Hmax = np.max(np.max(dsm)-np.min(dsm[dsm>0]))
    H = np.arange(resolution,Hmax,resolution)
    Shmax = np.zeros(np.shape(dsm))
    Iact = dsm
    for jj in range(len(H)):
        tmp = reconstruction(Iact-H[jj], Iact, method='dilation')
        hnew = imregionalmax(tmp)
        if jj>2:
            hnew = hnew | hant;
            hnew = scipy.ndimage.binary_fill_holes(hnew)
        Shmax += hnew
        hant = hnew
    GShmax = scipy.ndimage.morphology.grey_dilation(Shmax,size=3)-scipy.ndimage.morphology.grey_erosion(Shmax,size=3)
    Lhmax = skeletonize(imextendedmax(Shmax,h))
    SE = [[1,1,1],[1,1,1],[1,1,1]]
    markers = scipy.ndimage.label(Lhmax,structure=SE)[0]
    Sp1 = skimage.morphology.watershed((np.max(Shmax)-Shmax),markers)
    npoly = np.ones(np.shape(poly))
    npoly[poly] = 0
    Sp1[npoly.astype(bool)] = 0
    GSp1 = scipy.ndimage.morphology.grey_dilation(Sp1,size=3)-scipy.ndimage.morphology.grey_erosion(Sp1,size=3)
    markers = scipy.ndimage.label((Lhmax +GSp1>0)>0,structure=SE)[0]
    Sp1 = skimage.morphology.watershed(GShmax,markers)
    Sp1[npoly.astype(bool)] = 0
    Sp1[Sp1==1]=0
    Sp1 = eliminatenoise(Sp1)
    return Sp1
