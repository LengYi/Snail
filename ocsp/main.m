//
//  main.m
//  ocsp
//
//  Created by lemon4ex on 2017/10/19.
//  Copyright © 2017年 lemon4ex. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <openssl/bio.h>
#include <openssl/ocsp.h>

int main(int argc, const char * argv[]) {
    // http: //ocsp.apple.com/ocsp02-wwdr01/ME4wTKADAgEAMEUwQzBBMAkGBSsOAwIaBQAEFADrDMz0cWy6RiOj1S%2BY1D32MKkdBBSIJxcJqbYYYIvs67r2R1nFUlSjtwIITqfIJQvOPRc%3D
    // 访问上面的网址，返回的内容即为der文件。
    BIO *derbio = BIO_new_file("/Users/lemon4ex/Desktop/123.der","r");
    // BIO *BIO_new_mem_buf(void *buf, int len); 从内存数据中读取
    OCSP_RESPONSE *resp = d2i_OCSP_RESPONSE_bio(derbio, NULL);
    BIO_free(derbio);
    if (resp == NULL) {
        printf("Error reading OCSP response\n");
        return 0;
    }
    int status = OCSP_response_status(resp);
    const char *str = OCSP_response_status_str(status);
    printf("status %d -> %s\n",status,str);
    if (status != OCSP_RESPONSE_STATUS_SUCCESSFUL) {
        printf("ocsp response error");
        return 0;
    }
    OCSP_BASICRESP *baseResp = OCSP_response_get1_basic(resp);
    int count = OCSP_resp_count(baseResp);
    for (int i = 0; i < count; ++i) {
        OCSP_SINGLERESP *singleResp = OCSP_resp_get0(baseResp, i);
        int reason = 0;
        int certStatus = OCSP_single_get0_status(singleResp, &reason, NULL,NULL,NULL);
        switch (certStatus) {
            case V_OCSP_CERTSTATUS_GOOD:
                printf("status %d -> %s\n",certStatus,OCSP_response_status_str(certStatus));
                break;
            case V_OCSP_CERTSTATUS_REVOKED:
                printf("status %d, reason %d -> %s\n",certStatus,reason,OCSP_crl_reason_str(reason));
                break;
            case V_OCSP_CERTSTATUS_UNKNOWN:
                printf("status unknow");
                break;
            default:
                break;
        }
        // 不需要释放，否则挂掉
        //            OCSP_SINGLERESP_free(singleResp);
        //            singleResp = NULL;
    }
    OCSP_BASICRESP_free(baseResp);
    baseResp = NULL;
    OCSP_RESPONSE_free(resp);
    resp = NULL;
    return 0;
}
