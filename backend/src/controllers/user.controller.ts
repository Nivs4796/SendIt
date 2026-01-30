import { Request, Response, NextFunction } from 'express'
import * as userService from '../services/user.service'
import { formatResponse } from '../utils/helpers'

export const getProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await userService.getUserById(req.user!.id)
    res.status(200).json(formatResponse(true, 'Profile retrieved', { user }))
  } catch (error) {
    next(error)
  }
}

export const updateProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await userService.updateUser(req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Profile updated', { user }))
  } catch (error) {
    next(error)
  }
}

export const deleteAccount = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await userService.deleteUser(req.user!.id)
    res.status(200).json(formatResponse(true, 'Account deleted successfully'))
  } catch (error) {
    next(error)
  }
}

// Admin endpoints
export const listUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const search = req.query.search as string | undefined
    const result = await userService.listUsers(page, limit, search)
    res.status(200).json(formatResponse(true, 'Users retrieved', { users: result.users }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getUserById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await userService.getUserById(req.params.id as string)
    res.status(200).json(formatResponse(true, 'User retrieved', { user }))
  } catch (error) {
    next(error)
  }
}
