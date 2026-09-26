import { application } from './application'
import AutoSubmitController from './auto_submit_controller'
import ConfirmController from './confirm_controller'
import CursorController from './cursor_controller'
import DateShiftController from './date_shift_controller'
import DayChangeController from './day_change_controller'
import DialogController from './dialog_controller'
import FormResetController from './form_reset_controller'
import HotkeyController from './hotkey_controller'

application.register('auto-submit', AutoSubmitController)
application.register('confirm', ConfirmController)
application.register('cursor', CursorController)
application.register('date-shift', DateShiftController)
application.register('day-change', DayChangeController)
application.register('dialog', DialogController)
application.register('form-reset', FormResetController)
application.register('hotkey', HotkeyController)
