import { Router } from 'express'
import * as vehicleController from '../controllers/vehicle.controller'
import { authenticate, authorizePilot } from '../middleware/auth'
import { validate, createVehicleSchema, updateVehicleSchema, vehicleIdParamSchema } from '../validators'

const router = Router()

/**
 * @swagger
 * /vehicles/types:
 *   get:
 *     summary: Get all vehicle types
 *     tags: [Vehicles]
 *     responses:
 *       200:
 *         description: Vehicle types list
 */
router.get('/types', vehicleController.getVehicleTypes)

/**
 * @swagger
 * /vehicles:
 *   post:
 *     summary: Add a vehicle (Pilot only)
 *     tags: [Vehicles]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - vehicleTypeId
 *             properties:
 *               vehicleTypeId:
 *                 type: string
 *               registrationNo:
 *                 type: string
 *               model:
 *                 type: string
 *               color:
 *                 type: string
 *     responses:
 *       201:
 *         description: Vehicle added
 */
router.post('/', authenticate, authorizePilot, validate(createVehicleSchema), vehicleController.createVehicle)

/**
 * @swagger
 * /vehicles:
 *   get:
 *     summary: Get pilot's vehicles
 *     tags: [Vehicles]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Vehicles list
 */
router.get('/', authenticate, authorizePilot, vehicleController.getVehicles)

/**
 * @swagger
 * /vehicles/{id}:
 *   get:
 *     summary: Get vehicle by ID
 *     tags: [Vehicles]
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
 *         description: Vehicle details
 */
router.get('/:id', authenticate, authorizePilot, validate(vehicleIdParamSchema), vehicleController.getVehicle)

/**
 * @swagger
 * /vehicles/{id}:
 *   patch:
 *     summary: Update vehicle
 *     tags: [Vehicles]
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
 *               registrationNo:
 *                 type: string
 *               model:
 *                 type: string
 *               color:
 *                 type: string
 *               isActive:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Vehicle updated
 */
router.patch('/:id', authenticate, authorizePilot, validate(updateVehicleSchema), vehicleController.updateVehicle)

/**
 * @swagger
 * /vehicles/{id}:
 *   delete:
 *     summary: Delete vehicle
 *     tags: [Vehicles]
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
 *         description: Vehicle deleted
 */
router.delete('/:id', authenticate, authorizePilot, validate(vehicleIdParamSchema), vehicleController.deleteVehicle)

export default router
