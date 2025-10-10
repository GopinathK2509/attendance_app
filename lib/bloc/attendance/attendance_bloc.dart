import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_attendance_application/bloc/attendance/attendance_events.dart';
import 'package:mobile_attendance_application/bloc/attendance/attendance_states.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/domain/repositories/attendance_respository.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository attendanceRepository;

  AttendanceBloc({required this.attendanceRepository})
    : super(AttendanceInitial()) {
    on<CheckInEvent>(_onCheckIn);
    on<CheckOutEvent>(_onCheckOut);
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<LoadAllAttendanceEvent>(_onLoadAllAttendance);
  }

  Future<void> _onCheckIn(
    CheckInEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = Location(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      final attendance = await attendanceRepository.checkIn(location);
      emit(CheckInSuccess(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(error: e.toString()));
    }
  }

  Future<void> _onCheckOut(
    CheckOutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final location = Location(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      final attendance = await attendanceRepository.checkOut(location);
      emit(CheckOutSuccess(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(error: e.toString()));
    }
  }

  Future<void> _onLoadAttendance(
    LoadAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final records = await attendanceRepository.getUserAttendance(
        event.userId,
        event.dateRange,
      );
      final current = await attendanceRepository.getCurrentAttendance(
        event.userId,
      );
      emit(
        AttendanceSuccess(
          attendanceRecords: records,
          currentAttendance: current,
        ),
      );
    } catch (e) {
      emit(AttendanceError(error: e.toString()));
    }
  }

  Future<void> _onLoadAllAttendance(
    LoadAllAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final records = await attendanceRepository.getAllAttendance(
        dateRange: event.dateRange,
        department: event.department,
      );
      emit(AttendanceSuccess(attendanceRecords: records));
    } catch (e) {
      emit(AttendanceError(error: e.toString()));
    }
  }
}
