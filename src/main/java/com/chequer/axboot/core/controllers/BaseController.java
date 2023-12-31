package com.chequer.axboot.core.controllers;

import com.chequer.axboot.core.api.ApiException;
import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.code.ApiStatus;
import com.chequer.axboot.core.validator.CollectionValidator;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.TypeMismatchException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.InitBinder;

import javax.inject.Inject;
import java.sql.SQLException;

@ControllerAdvice
public class BaseController {

    @Inject
    protected LocalValidatorFactoryBean validator;

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.addValidators(new CollectionValidator(validator));
    }

    protected static final String APPLICATION_JSON = "application/json; charset=UTF-8";

    protected static final String TEXT_PLAIN_UTF_8 = "text/plain; charset=UTF-8";

    private static final Logger logger = LoggerFactory.getLogger(BaseController.class);

    public ApiResponse ok() {
        return ApiResponse.of(ApiStatus.SUCCESS, "SUCCESS");
    }

    public ApiResponse ok(String message) {
        return ApiResponse.of(ApiStatus.SUCCESS, message);
    }
    
    public ApiResponse error(Exception e) {
    	errorLogging(e);
        return ApiResponse.error(ApiStatus.SYSTEM_ERROR, e.getCause().getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ApiResponse handleForbidden(Exception e) {
        return ApiResponse.error(ApiStatus.FORBIDDEN, e.getMessage());
    }

    @ExceptionHandler(TypeMismatchException.class)
    public ApiResponse handleBadRequestException(Exception e) {
        errorLogging(e);
        return ApiResponse.error(ApiStatus.BAD_REQUEST, "BAD_REQUEST");
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ApiResponse handleRequestParameterException(MissingServletRequestParameterException e) {
        errorLogging(e);
        return ApiResponse.error(ApiStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(ApiException.class)
    public ApiResponse handleApiException(ApiException apiException) {
        return ApiResponse.error(ApiStatus.getApiStatus(apiException.getCode()), apiException.getMessage());
    }

    @ExceptionHandler(Throwable.class)
    public ApiResponse handleException(Throwable throwable) {
        errorLogging(throwable);

        ApiResponse apiResponse = ApiResponse.error(ApiStatus.SYSTEM_ERROR, throwable.getMessage());
        Throwable rootCause = ExceptionUtils.getRootCause(throwable);

        if (rootCause != null) {
            if (rootCause instanceof SQLException) {
                String message = String.format(rootCause.getLocalizedMessage());
                apiResponse = ApiResponse.error(ApiStatus.SYSTEM_ERROR, message);
            }
        }
        return apiResponse;
    }

    protected void errorLogging(Throwable throwable) {
        if (logger.isErrorEnabled()) {

            Throwable rootCause = ExceptionUtils.getRootCause(throwable);

            if (rootCause != null) {
                throwable = rootCause;
            }

            if (throwable.getMessage() != null) {
                logger.error(throwable.getMessage(), throwable);
            } else {
                logger.error("ERROR", throwable);
            }
        }
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Object processValidationError(MethodArgumentNotValidException ex) {
        FieldError fieldError = ex.getBindingResult().getFieldErrors().get(0);
        ApiResponse error = ApiResponse.error(ApiStatus.SYSTEM_ERROR, fieldError.getDefaultMessage());
        error.getError().setRequiredKey(fieldError.getField());
        return error;
    }

    @ExceptionHandler(NullPointerException.class)
    public ApiResponse javaNullPointerError(Exception e) {
        errorLogging(e);
        return ApiResponse.error(ApiStatus.SYSTEM_ERROR, "프로그램 오류(javaNullPointerError)");
    }
}
