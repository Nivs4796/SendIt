import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      phone: true,
      email: true,
      name: true,
      avatar: true,
      isVerified: true,
      isActive: true,
      createdAt: true,
      addresses: true,
      _count: {
        select: { bookings: true, reviews: true },
      },
    },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  return user
}

export const updateUser = async (
  id: string,
  data: { name?: string; email?: string; avatar?: string }
) => {
  const user = await prisma.user.update({
    where: { id },
    data,
    select: {
      id: true,
      phone: true,
      email: true,
      name: true,
      avatar: true,
      isVerified: true,
      updatedAt: true,
    },
  })

  return user
}

export const deleteUser = async (id: string) => {
  await prisma.user.update({
    where: { id },
    data: { isActive: false },
  })
}

export const listUsers = async (page: number = 1, limit: number = 10, search?: string) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = search
    ? {
        OR: [
          { name: { contains: search, mode: 'insensitive' as const } },
          { phone: { contains: search } },
          { email: { contains: search, mode: 'insensitive' as const } },
        ],
      }
    : {}

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        phone: true,
        email: true,
        name: true,
        avatar: true,
        isVerified: true,
        isActive: true,
        createdAt: true,
        _count: { select: { bookings: true } },
      },
    }),
    prisma.user.count({ where }),
  ])

  return {
    users,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}
