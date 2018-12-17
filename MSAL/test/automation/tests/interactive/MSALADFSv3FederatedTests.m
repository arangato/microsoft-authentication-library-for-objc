//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "MSALADFSBaseUITest.h"
#import "XCTestCase+TextFieldTap.h"
#import "NSString+MSIDAutomationUtils.h"

@interface MSALADFSv3FederatedTests : MSALADFSBaseUITest

@end

@implementation MSALADFSv3FederatedTests

- (void)setUp
{
    [super setUp];

    MSIDTestAutomationConfigurationRequest *configurationRequest = [MSIDTestAutomationConfigurationRequest new];
    configurationRequest.accountProvider = MSIDTestAccountProviderADfsv3;
    configurationRequest.appVersion = MSIDAppVersionV1;
    [self loadTestConfiguration:configurationRequest];
}

#pragma mark - Tests

// #290995 iteration 11
- (void)testInteractiveADFSv3Login_withPromptAlways_noLoginHint_andSystemWebView
{
    NSString *environment = self.class.confProvider.wwEnvironment;
    MSIDAutomationTestRequest *request = [self.class.confProvider defaultNonConvergedAppRequest];
    request.configurationAuthority = [self.class.confProvider defaultAuthorityForIdentifier:environment tenantId:@"organizations"];
    request.requestScopes = [self.class.confProvider scopesForEnvironment:environment type:@"aad_graph_static"];
    request.expectedResultScopes = request.requestScopes;
    request.uiBehavior = @"force";
    request.testAccount = self.primaryAccount;

    // 1. Do interactive login
    NSString *homeAccountId = [self runSharedADFSInteractiveLoginWithRequest:request];
    XCTAssertNotNil(homeAccountId);

    // 2. Now do silent login #296725
    request.homeAccountIdentifier = homeAccountId;
    request.cacheAuthority = [self.class.confProvider defaultAuthorityForIdentifier:environment tenantId:self.primaryAccount.targetTenantId];
    [self runSharedSilentAADLoginWithTestRequest:request];
}

- (void)testInteractiveADFSv3Login_withPromptAlways_withLoginHint_andSafariViewController
{
    NSString *environment = self.class.confProvider.wwEnvironment;
    MSIDAutomationTestRequest *request = [self.class.confProvider defaultNonConvergedAppRequest];
    request.configurationAuthority = [self.class.confProvider defaultAuthorityForIdentifier:environment tenantId:@"organizations"];
    request.requestScopes = [self.class.confProvider scopesForEnvironment:environment type:@"ms_graph"];
    request.expectedResultScopes = [NSString msidCombinedScopes:request.requestScopes withScopes:[self.class.confProvider scopesForEnvironment:environment type:@"oidc"]];
    request.uiBehavior = @"force";
    request.testAccount = self.primaryAccount;
    request.webViewType = MSIDWebviewTypeSafariViewController;
    request.loginHint = self.primaryAccount.username;

    // Do interactive login
    NSString *homeAccountId = [self runSharedADFSInteractiveLoginWithRequest:request];
    XCTAssertNotNil(homeAccountId);
}

- (void)testInteractiveADFSv3Login_withPromptAlways_withLoginHint_andEmbeddedWebView
{
    NSString *environment = self.class.confProvider.wwEnvironment;
    MSIDAutomationTestRequest *request = [self.class.confProvider defaultConvergedAppRequest:environment];
    request.configurationAuthority = [self.class.confProvider defaultAuthorityForIdentifier:environment tenantId:@"organizations"];
    request.requestScopes = [self.class.confProvider scopesForEnvironment:environment type:@"ms_graph"];
    request.expectedResultScopes = [NSString msidCombinedScopes:request.requestScopes withScopes:[self.class.confProvider scopesForEnvironment:environment type:@"oidc"]];
    request.uiBehavior = @"force";
    request.testAccount = self.primaryAccount;
    request.webViewType = MSIDWebviewTypeWKWebView;
    request.loginHint = self.primaryAccount.username;

    // Do interactive login
    NSString *homeAccountId = [self runSharedADFSInteractiveLoginWithRequest:request];
    XCTAssertNotNil(homeAccountId);
}

@end