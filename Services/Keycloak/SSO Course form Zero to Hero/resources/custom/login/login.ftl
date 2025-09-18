<#import "template.ftl" as layout>
  <@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section="header">
      <h2 class="my-4 text-center font-light text-3xl">
        ${msg("loginAccountTitle")}
      </h2>
      <#elseif section="form">
        <div id="kc-form">
          <div id="kc-form-wrapper">
            <#if realm.password>
              <form id="kc-form-login" class="space-y-6 mt-10" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                <#if !usernameHidden??>
                  <div class="${properties.kcFormGroupClass!} flex flex-col">
                    <label for="username" class="${properties.kcLabelClass!}">
                      <#if !realm.loginWithEmailAllowed>
                        ${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>
                          ${msg("usernameOrEmail")}
                          <#else>
                            ${msg("email")}
                      </#if>
                    </label>
                    <input tabindex="1" id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="off"
                      aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                    <#if messagesPerField.existsError('username','password')>
                      <span id="input-error" class="${properties.kcInputErrorMessageClass!} text-red-600" aria-live="polite">
                        ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                      </span>
                    </#if>
                  </div>
                </#if>
                <div class="${properties.kcFormGroupClass!} flex flex-col">
                  <label for="password" class="${properties.kcLabelClass!}">
                    ${msg("password")}
                  </label>
                  <input tabindex="2" id="password" class="${properties.kcInputClass!}" name="password" type="password" autocomplete="off"
                    aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                  <#if usernameHidden?? && messagesPerField.existsError('username','password')>
                    <span id="input-error" class="${properties.kcInputErrorMessageClass!} text-red-600" aria-live="polite">
                      ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                    </span>
                  </#if>
                </div>
                <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!} flex justify-between">
                  <div id="kc-form-options">
                    <#if realm.rememberMe && !usernameHidden??>
                      <div class="checkbox">
                        <label class="text-base flex items-center space-x-2 cursor-pointer">
                          <#if login.rememberMe??>
                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked>
                            <span>
                              ${msg("rememberMe")}
                            </span>
                            <#else>
                              <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox">
                              <span>
                                ${msg("rememberMe")}
                              </span>
                          </#if>
                        </label>
                      </div>
                    </#if>
                  </div>
                  <div class="${properties.kcFormOptionsWrapperClass!} text-sm text-blue-500 hover:text-blue-600 hover:underline">
                    <#if realm.resetPasswordAllowed>
                      <a tabindex="5" href="${url.loginResetCredentialsUrl}">
                        ${msg("doForgotPassword")}
                      </a>
                    </#if>
                  </div>
                </div>
                <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                  <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"
            </#if>/>
            <input tabindex="4" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!} w-full py-2 text-lg font-semibold text-center text-white border-none bg-green-500 hover:bg-green-600 outline-none rounded-md cursor-pointer" name="login" id="kc-login" type="submit" value="${msg("doLogIn")}" />
          </div>
          </form>
    </#if>
    </div>
    </div>
    <#elseif section="info">
      <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
        <div id="kc-registration-container" class="my-4 text-center">
          <div id="kc-registration">
            <p>
              ${msg("noAccount")}
              <a tabindex="6" href="${url.registrationUrl}" class="text-blue-500 hover:text-blue-600 hover:underline">
                ${msg("doRegister")}
              </a>
            </p>
          </div>
        </div>
      </#if>
      <#elseif section="socialProviders">
        <#if realm.password && social.providers??>
          <div id="kc-social-providers" class="${properties.kcFormSocialAccountSectionClass!}">
            <div class="my-4 flex flex-col items-center justify-center">
              <div class="relative h-px w-full bg-stone-200 top-[0.7rem]
 -z-10"></div>
              <span class="text-stone-400 text-sm uppercase font-semibold bg-white px-2">
                ${msg("identity-provider-login-label")}
              </span>
            </div>
            <ul class="${properties.kcFormSocialAccountListClass!}
<#if social.providers?size gt 3>
${properties.kcFormSocialAccountListGridClass!}
</#if> grid grid-cols-2 gap-2">
              <#list social.providers as p>
                <li class="text-center text-gray-600 hover:text-black border border-gray-200 hover:bg-gray-200 rounded">
                  <a id="social-${p.alias}" class="${properties.kcFormSocialAccountListButtonClass!}
<#if social.providers?size gt 3>
${properties.kcFormSocialAccountGridItem!}
</#if>"
                    type="button" href="${p.loginUrl}">
                    <#if p.iconClasses?has_content>
                      <div class="py-2 flex items-center justify-center space-x-2">
                        <i class="${properties.kcCommonLogoIdP!} ${p.iconClasses!}" aria-hidden="true"></i>
                        <span class="${properties.kcFormSocialAccountNameClass!} kc-social-icon-text">
                          ${p.displayName!}
                        </span>
                      </div>
                      <#else>
                        <div class="${properties.kcFormSocialAccountNameClass!}">
                          ${p.displayName!}
                        </div>
                    </#if>
                  </a>
                </li>
              </#list>
            </ul>
          </div>
        </#if>
        </#if>
  </@layout.registrationLayout>
