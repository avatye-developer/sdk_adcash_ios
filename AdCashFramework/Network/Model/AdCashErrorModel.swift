//
//  AdCashErrorModal.swift
//  AvatyeAdCash
//
//  Created by 임재혁 on 2023/08/11.
//

import UIKit

@objcMembers
public class AdCashErrorModel: NSObject {
    public let code: Int
    public let type: String
    public let message: String
    public let desc: String
    
    init(code: Int, type: String, message: String, desc: String) {
        self.code = code
        self.type = type
        self.message = message
        self.desc = desc
    }
}

@objc
enum AdCashError: Int{
    case EXCEPTION_UNKNOWN = 0
    case SERVER_TIMEOUT
    case INVALID_PARAMETER
    case NOT_EXISTS_AD
    case FAIL_OPEN
    case LOAD_TIMEOUT
    case BLOCKED
    case EXCEPTION_KNOWN
    case NEED_AGE_VERIFICATION
    case INVALID_APID_KEY
    case NOT_EXSITS_APID_CAMPAIGN
    case NOT_LOADED
    
    var error: AdCashErrorModel{
        switch self{
        case .EXCEPTION_UNKNOWN:
            return AdCashErrorModel(code: 9000, type: "EXCEPTION", message: "exception", desc: "알 수 없는 에러가 발생되었습니다.(unknown)")
        case .SERVER_TIMEOUT:
            return AdCashErrorModel(code: 9002, type: "SERVER_TIMEOUT", message: "server timeout", desc: "서버 요청 시간이 경과되었습니다.")
        case .INVALID_PARAMETER:
            return AdCashErrorModel(code: 9100, type: "INVALID_PARAMETER", message: "invalid parameter", desc: "광고 네트워크 파라미터 정보가 올바르지 않습니다.")
        case .NOT_EXISTS_AD:
            return AdCashErrorModel(code: 9200, type: "NOT_EXISTS_AD", message: "not exists ad", desc: "광고가 없습니다.")
        case .FAIL_OPEN:
            return AdCashErrorModel(code: 9300, type: "FAIL_OPEN", message: "advertise open failed", desc: "광고가 정상적으로 노출되지 않았습니다.(동영상 광고)")
        case .LOAD_TIMEOUT:
            return AdCashErrorModel(code: 9400, type: "LOAD_TIMEOUT", message: "advertise load time out(video)", desc: "광고 로드 시간이 경과 되었습니다.")
        case .BLOCKED:
            return AdCashErrorModel(code: 9999, type: "BLOCKED", message: "blocked", desc: "애드 블록 또는 프록시 사용으로 인해 광고 정보를 확인 할 수 없습니다.")
        case .EXCEPTION_KNOWN:
            return AdCashErrorModel(code: 1000, type: "EXCEPTION", message: "exception", desc: "일반적인 에러가 발생되었습니다.(Known)")
        case .NEED_AGE_VERIFICATION:
            return AdCashErrorModel(code: 1100, type: "NEED_AGE_VERIFICATION", message: "need age verification", desc: "유저 나이 인증 정보가 없습니다.")
        case .INVALID_APID_KEY:
            return AdCashErrorModel(code: 1200, type: "INVALID_APID_KEY", message: "invalid apid key", desc: "애드캐시 지면정보가 올바르지 않습니다.")
        case .NOT_EXSITS_APID_CAMPAIGN:
            return AdCashErrorModel(code: 1300, type: "NOT_EXSITS_APID_CAMPAIGN", message: "not exists apid campaign", desc: "애드캐시 지면에 설정된 광고가 존재하지 않습니다.")
        case .NOT_LOADED:
            return AdCashErrorModel(code: 1400, type: "NOT_LOADED", message: "advertise is not loaded(loader is not ready)", desc: "광고 정보가 로드되지 않았습니다.")
        }
    }
}
