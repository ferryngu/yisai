//
//  FEHttpErrorCode.swift
//  FECore
//
//  Created by apps on 15/10/14.
//  Copyright © 2015年 apps. All rights reserved.
//

import Foundation

func get_fe_http_err_string(httpError:Int32)->String {
    
    if FE_HTTP_ERROR_NONE == httpError {
        
        return "FE_HTTP_ERROR_NONE"
        
    } else if FE_HTTP_ERROR_CONNECT == httpError {
   
        return "FE_HTTP_ERROR_CONNECT"

    } else if FE_HTTP_ERROR_RESOLVE == httpError {
        
        return "FE_HTTP_ERROR_RESOLVE"
        
    } else if FE_HTTP_ERROR_INTERRUPT == httpError{
    
        return "FE_HTTP_ERROR_INTERRUPT"

    } else if FE_HTTP_ERROR_CANCEL == httpError {
        
        return "FE_HTTP_ERROR_CANCEL"
        
    } else if FE_HTTP_ERROR_40X == httpError {
        
        return "FE_HTTP_ERROR_40X"
        
    } else if FE_HTTP_ERROR_50X == httpError {
        
        return "FE_HTTP_ERROR_50X"
        
    } else if FE_HTTP_ERROR_TIMEOUT == httpError {
        
        return "FE_HTTP_ERROR_TIMEOUT"
        
    } else if FE_HTTP_ERROR_CREATEFILE == httpError {
        
        return "FE_HTTP_ERROR_CREATEFILE"
        
    } else if FE_HTTP_ERROR_FILESYSTEM == httpError {
        
        return "FE_HTTP_ERROR_FILESYSTEM"
        
    } else if FE_HTTP_ERROR_ADDQUEUE == httpError {
        
        return "FE_HTTP_ERROR_ADDQUEUE"
        
    } else if FE_HTTP_ERROR_FILESYSTEM == httpError {
        
        return "FE_HTTP_ERROR_FILESYSTEM"
        
    } else if FE_HTTP_ERROR_NETWORK == httpError {
        
        return "FE_HTTP_ERROR_NETWORK"
        
    } else if FE_HTTP_ERROR_OTHER == httpError {
        
        return "FE_HTTP_ERROR_OTHER"
        
    } else {
        
        return "FE_HTTP_ERROR_UNKNOW"
        
    }
    
}