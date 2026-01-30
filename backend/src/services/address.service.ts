import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'

interface CreateAddressInput {
  userId: string
  label: string
  address: string
  landmark?: string
  city: string
  state: string
  pincode: string
  lat: number
  lng: number
  isDefault?: boolean
}

export const createAddress = async (input: CreateAddressInput) => {
  const { userId, isDefault, ...data } = input

  // If setting as default, unset other defaults
  if (isDefault) {
    await prisma.address.updateMany({
      where: { userId, isDefault: true },
      data: { isDefault: false },
    })
  }

  const address = await prisma.address.create({
    data: { ...data, userId, isDefault: isDefault || false },
  })

  return address
}

export const getAddressById = async (id: string, userId: string) => {
  const address = await prisma.address.findUnique({ where: { id } })

  if (!address) {
    throw new AppError('Address not found', 404)
  }

  if (address.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  return address
}

export const updateAddress = async (
  id: string,
  userId: string,
  data: Partial<CreateAddressInput>
) => {
  const address = await prisma.address.findUnique({ where: { id } })

  if (!address) {
    throw new AppError('Address not found', 404)
  }

  if (address.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  // If setting as default, unset other defaults
  if (data.isDefault) {
    await prisma.address.updateMany({
      where: { userId, isDefault: true, id: { not: id } },
      data: { isDefault: false },
    })
  }

  const updated = await prisma.address.update({ where: { id }, data })
  return updated
}

export const deleteAddress = async (id: string, userId: string) => {
  const address = await prisma.address.findUnique({ where: { id } })

  if (!address) {
    throw new AppError('Address not found', 404)
  }

  if (address.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  await prisma.address.delete({ where: { id } })
}

export const getUserAddresses = async (userId: string) => {
  const addresses = await prisma.address.findMany({
    where: { userId },
    orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
  })
  return addresses
}
