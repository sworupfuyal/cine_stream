import 'package:cine_stream/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract interface class UsecaseWithParams<SuccessType,params>{
  Future<Either<Failure,SuccessType>> call(params params);
}

abstract interface class UseecaseWithoutParams<SuccessType>{
  Future<Either<Failure,SuccessType>> call();
}