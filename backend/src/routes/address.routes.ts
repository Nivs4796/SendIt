import { Router } from 'express'
import * as addressController from '../controllers/address.controller'
import { authenticate, authorizeUser } from '../middleware/auth'
import { validate, createAddressSchema, updateAddressSchema, addressIdParamSchema } from '../validators'

const router = Router()

/**
 * @swagger
 * /addresses:
 *   post:
 *     summary: Create a new address
 *     tags: [Addresses]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - label
 *               - address
 *               - city
 *               - state
 *               - pincode
 *               - lat
 *               - lng
 *             properties:
 *               label:
 *                 type: string
 *               address:
 *                 type: string
 *               landmark:
 *                 type: string
 *               city:
 *                 type: string
 *               state:
 *                 type: string
 *               pincode:
 *                 type: string
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *               isDefault:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Address created
 */
router.post('/', authenticate, authorizeUser, validate(createAddressSchema), addressController.createAddress)

/**
 * @swagger
 * /addresses:
 *   get:
 *     summary: Get all user addresses
 *     tags: [Addresses]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Addresses list
 */
router.get('/', authenticate, authorizeUser, addressController.getAddresses)

/**
 * @swagger
 * /addresses/{id}:
 *   get:
 *     summary: Get address by ID
 *     tags: [Addresses]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Address details
 *       404:
 *         description: Address not found
 */
router.get('/:id', authenticate, authorizeUser, validate(addressIdParamSchema), addressController.getAddress)

/**
 * @swagger
 * /addresses/{id}:
 *   patch:
 *     summary: Update address
 *     tags: [Addresses]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               label:
 *                 type: string
 *               address:
 *                 type: string
 *               city:
 *                 type: string
 *               state:
 *                 type: string
 *               pincode:
 *                 type: string
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *               isDefault:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Address updated
 */
router.patch('/:id', authenticate, authorizeUser, validate(updateAddressSchema), addressController.updateAddress)

/**
 * @swagger
 * /addresses/{id}:
 *   delete:
 *     summary: Delete address
 *     tags: [Addresses]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Address deleted
 */
router.delete('/:id', authenticate, authorizeUser, validate(addressIdParamSchema), addressController.deleteAddress)

export default router
