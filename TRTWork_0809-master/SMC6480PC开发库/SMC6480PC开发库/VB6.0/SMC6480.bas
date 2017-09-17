Attribute VB_Name = "Module1"
Option Explicit
''''''''''''''''''''''''''''''''''  Leadshine technology  ''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''DMC6480'''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Data Type define
'by zxq
'Data 2010/04/26
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
'G code error sign start
Global Const ERR_GSTOP_OFFSET = 2000
Global Const ERR_GSTOP_EMG = ERR_GSTOP_OFFSET + 1                       'EMGֹͣ
Global Const ERR_GSTOP_EL = ERR_GSTOP_OFFSET + 2                        '��λֹͣ
Global Const ERR_GSTOP_GFILE_TYPE_ERR = ERR_GSTOP_OFFSET + 3            '���ͳ���
Global Const ERR_GSTOP_STOPKEYDOWN = ERR_GSTOP_OFFSET + 4               'ֹͣ�����£���������
Global Const ERR_GSTOP_LOOPERR = ERR_GSTOP_OFFSET + 5                   'ѭ������, ��������
Global Const ERR_GSTOP_SUBERR = ERR_GSTOP_OFFSET + 6                    '�ӳ�����ó���, ��ι����
Global Const ERR_GSTOP_NLINEERR = ERR_GSTOP_OFFSET + 7                  '��ӦN�к��Ҳ���
Global Const ERR_GSTOP_NOTSUPPORT = ERR_GSTOP_OFFSET + 8                '��֧�ֵ�G����
Global Const ERR_GSTOP_FILEEND = ERR_GSTOP_OFFSET + 9                  '�ļ��쳣����
Global Const ERR_GSTOP_SOFTLIMITED = ERR_GSTOP_OFFSET + 10              '����λֹͣ
Global Const ERR_GSTOP_GLINE_PARA_ERR = ERR_GSTOP_OFFSET + 11           '�����ȳ���
Global Const ERR_GSTOP_TASKERR = ERR_GSTOP_OFFSET + 12                  '���������
Global Const ERR_GSTOP_USER_FORCEEND = ERR_GSTOP_OFFSET + 13            'ǿ��ֹͣ
Global Const ERR_GSTOP_GFILECHECKERR = ERR_GSTOP_OFFSET + 14            'g�ļ�������
Global Const ERR_GSTOP_GFILEIDERR = ERR_GSTOP_OFFSET + 15               'g�ļ��Ŵ���
Global Const ERR_GSTOP_ALM = ERR_GSTOP_OFFSET + 16                      'g�ļ��Ŵ���
Global Const ERR_GSTOP_UNKNOWN = ERR_GSTOP_OFFSET + 30                  '�����ܵĴ���
'G code error sign end


'system status start
Global Const SYS_STATE_IDLE = 1                                         '����
Global Const SYS_STATE_GRUNNING = 3                                    '����
Global Const SYS_STATE_MANUALING = 4                                    '�ֶ�
Global Const SYS_STATE_PAUSE = 5                                        '��ͣ
Global Const SYS_STATE_GEDIT = 6                                        '����༭
Global Const SYS_STATE_SETTING = 7                                       '����'
Global Const SYS_STATE_TEST = 8                                        '����
Global Const SYS_STATE_GFILEREVIEW = 9                                 'gfile ���
Global Const SYS_STATE_UDISK = 10                                     'U�̲���
Global Const SYS_STATE_GTEACHING = 11                                  'ʾ��
Global Const SYS_STATE_CANNOT_CONNECT = 50                             '���Ӳ���
'system status end



'return error code start
Global Const ERR_SUCCESS = 0
Global Const ERR_OK = 0

Global Const ERRCODE_UNKNOWN = 1
Global Const ERRCODE_PARAERR = 2
Global Const ERRCODE_TIMEOUT = 3
Global Const ERRCODE_CONTROLLERBUSY = 4
Global Const ERRCODE_CONNECT_TOOMANY = 5
Global Const ERRCODE_OS_ERR = 6
Global Const ERRCODE_CANNOT_OPEN_COM = 7
Global Const ERRCODE_CANNOT_CONNECTETH = 8
Global Const ERRCODE_HANDLEERR = 9                                      '���Ӵ���
Global Const ERRCODE_SENDERR = 10                                       '���Ӵ���
Global Const ERRCODE_GFILE_ERR = 11                                     'G�ļ��﷨����
Global Const ERRCODE_FIRMWAREERR = 12                                  '�̼��ļ�����
Global Const ERRCODE_FILENAME_TOOLONG = 13                             '�ļ���̫��
Global Const ERRCODE_FIRMWAR_MISMATCH = 14                              '�̼��ļ���ƥ��
Global Const ERRCODE_CARD_NOTSUPPORT = 15                              '��Ӧ�Ŀ���֧���������
Global Const ERRCODE_BUFFER_TOO_SMALL = 15                              '����Ļ���̫С
Global Const ERRCODE_NEED_PASSWORD = 16                                 '���뱣��
Global Const ERRCODE_PASSWORD_ENTER_TOOFAST = 17                        '��������̫��
Global Const ERRCODE_GET_LENGTH_ERR = 100                                '�յ������ݰ��ĳ��ȴ��� ���������ɺ󲻻����, �ַ����ӿ�ʱ���ܳ������峤��
Global Const ERRCODE_COMPILE_OFFSET = 1000                               '�ļ��������
Global Const ERRCODE_CONTROLLERERR_OFFSET = 100000                      '���������洫���Ĵ��󣬼������ƫ��
'return error code end


'link type start
Global Const SMC6X_CONNECTION_COM = 1                                   'COM
Global Const SMC6X_CONNECTION_ETH = 2                                   'LAN
Global Const SMC6X_CONNECTION_USB = 3                                   'USB
Global Const SMC6X_CONNECTION_PCI = 4                                   'PCI
Global Const SMC6X_DEFAULT_TIMEOUT = 5000                               'ȱʡ�ĵȴ�ʱ��
Global Const SMC6X_DEFAULT_TIMEOUT_COM = 5000                          '������ʱ
'link type end

'define controller handle start
'public Dim SMCHANDLE As Object


'define controller handle end

'assistant axis start
  Global Const SMC_AXIS_X = 0
  Global Const SMC_AXIS_Y = 1
  Global Const SMC_AXIS_Z = 2
  Global Const SMC_AXIS_U = 3

  Global Const SMC_AXIS_NUM_VECT = &HFE
  Global Const SMC_AXIS_NUM_ALL = &HFF
'assistant axis end


'
'//�����
Global Const SMC_IN_VALIDVALUE = 0          '��Ч��ƽ��ͨ��IOΪ�͵�ƽ, ԭ����λ�źŵĵ�ƽ��������
Global Const SMC_IN_INVALIDVALUE = 1         '�ߵ�ƽ
'
'//�����
Global Const SMC_OUT_VALIDVALUE = 0          '��Ч��ƽ��ͨ��IOΪ�͵�ƽ, ���л���ʼ��ƽ�������ƽ���෴
Global Const SMC_OUT_INVALIDVALUE = 1        '�ߵ�ƽ

Global Const SMC_IONUM_1 = 1
Global Const SMC_IONUM_24 = 24
Global Const SMC_IONUM_PWM1 = 41
Global Const SMC_IONUM_PWM2 = 42
Global Const SMC_IONUM_DA1 = 51
Global Const SMC_IONUM_DA2 = 52
Global Const SMC_IONUM_LED1 = 61
Global Const SMC_IONUM_LED2 As Integer = 62 'zxq
Global Const SMC_IONUM_PWM1_FREQENCY = 71
Global Const SMC_IONUM_PWM2_FREQENCY = 72



Global Const VECTMOVE_STATE_RUNING = 1
Global Const VECTMOVE_STATE_PAUSE = 2
Global Const VECTMOVE_STATE_STOP = 3




Type struct_AxisStates
    m_axisnum As Byte
    m_HomeState As Byte
    m_AlarmState As Byte
    m_SDState As Byte
    m_INPState As Byte
    m_ElDecState As Byte
    m_ElPlusState As Byte
    m_HandWheelAState As Byte
    m_HandWheelBState As Byte
    m_EncodeAState As Byte '//6200û������ź�
    m_EncodeBState As Byte '//6200û������ź�
    m_ClearState As Byte '//6200û������ź�
    '//��������λ�ź�
    m_SoftElDecState As Byte '//0- ��Ч
    m_SoftElPlusState As Byte

End Type



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''                                 DMC6480 V1.0 �����б�                           ''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'˵��: ���������������
'����: ��
'���: ������handle
'����ֵ: ������
'*************************************************************/
Declare Function SMCOpen Lib "smc6x.dll" (ByVal types As Long, ByVal pconnectstring As String, ByRef phandle As Long) As Long
'int32 SMCOpen(SMC6X_CONNECTION_TYPE type, char *pconnectstring ,SMCHANDLE * phandle);



'/*************************************************************
'˵��: ���������������
'����: ��
'���: ������handle
'����ֵ: ������
'*************************************************************/
'int32 SMCOpenCom(uint comid, SMCHANDLE * phandle);
Declare Function SMCOpenCom Lib "smc6x.dll" (ByVal comid As Long, ByRef phandle As Long) As Long



'˵��: ���������������
'���룺IP��ַ���ַ����ķ�ʽ����
'���: ������handle
'����ֵ: ������
'*************************************************************/
'int32 SMCOpenEth(char *ipaddr, SMCHANDLE * phandle);
Declare Function SMCOpenEth Lib "smc6x.dll" (ByVal ipaddr As String, ByRef phandle As Long) As Long

'/*************************************************************
'˵��: ���������������
'���룺IP��ַ��32λ����IP��ַ����, ע���ֽ�˳��
'���: ������handle
'����ֵ: ������
'*************************************************************/
'int32 SMCOpenEth2(struct in_addr straddr, SMCHANDLE * phandle);
Declare Function SMCOpenEth2 Lib "smc6x.dll" (ByVal straddr As Long, ByRef phandle As Long) As Long


'/*************************************************************
'˵��: �رտ���������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/  zxq
'int32  SMCClose(SMCHANDLE  handle);
Declare Function SMCClose Lib "smc6x.dll" (ByVal handle As Long) As Long



'/*************************************************************
'˵��: �������ʱ�ȴ�ʱ��
'����: ������handle ����ʱ��
'���:
'����ֵ: ������
'*************************************************************/
'int32  SMCSetTimeOut(SMCHANDLE  handle, uint32 timems);
Declare Function SMCSetTimeOut Lib "smc6x.dll" (ByVal handle As Long, ByVal timems As Long) As Long

'/*************************************************************
'˵��: �������ʱ�ȴ�ʱ��
'����: ������handle
'���: ����ʱ��
'����ֵ: ������
'*************************************************************/
'int32  SMCGetTimeOut(SMCHANDLE  handle, uint32* ptimems);
Declare Function SMCGetTimeOut Lib "smc6x.dll" (ByVal handle As Long, ByRef timems As Long) As Long



'/*************************************************************
'˵��: ��ȡ��ʱ������Ľ���
'����: ������handle
'���:
'����ֵ�����ȣ� ���㣬
'*************************************************************/
'float  SMCGetProgress(SMCHANDLE  handle);
Declare Function SMCGetProgress Lib "smc6x.dll" (ByVal handle As Long) As Single


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'command function
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'/*************************************************************
'˵����//��ȡϵͳ״̬
'����: ������handle
'���: ״̬
'����ֵ: ������
'*************************************************************/
'int32 SMCGetState(SMCHANDLE handle,uint8 *pstate);
Declare Function SMCGetState Lib "smc6x.dll" (ByVal handle As Long, ByRef pState As Byte) As Long


'/*************************************************************
'˵����//��ȡ���ӿ�����������
'����: ������handle
'���:
'����ֵ������������0
'*************************************************************/
'uint8 SMCGetAxises(SMCHANDLE handle);
Declare Function SMCGetAxises Lib "smc6x.dll" (ByVal handle As Long) As Byte

'/*************************************************************
'˵��: ���س����ļ� ����ǰ�����һ��
'����: ������handle �ļ���
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownProgram(SMCHANDLE handle, const char* pfilename, const char* pfilenameinControl);
Declare Function SMCDownProgram Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String, ByVal pfilenameinControl As String) As Long

'/*************************************************************
'˵��: ���س����ļ� ����ǰ�����һ��
'���룺������handle buff ���������ļ�������
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownMemProgram(SMCHANDLE handle, const char* pbuffer, uint32 buffsize, const char* pfilenameinControl);
Declare Function SMCDownMemProgram Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As String, ByVal pfilenameinControl As String) As Long

'/*************************************************************
'˵��: ���س����ļ� ����ʱ�ļ���
'���룺������handle buff ���������ļ�������
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownProgramToTemp(SMCHANDLE handle, const char* pfilename);
Declare Function SMCDownProgramToTemp Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long



'/*************************************************************
'˵��: ���س����ļ� ����ʱ�ļ���
'���룺������handle buff ���������ļ�������
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownMemProgramToTemp(SMCHANDLE handle, const char* pbuffer, uint32 buffsize);
Declare Function SMCDownMemProgramToTemp Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long) As Long


'/*************************************************************
'˵��: ����
'���룺������handle �ļ����� ��ΪNULL��ʱ������ȱʡ�ļ�
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCRunProgramFile(SMCHANDLE handle, const char* pfilenameinControl);
Declare Function SMCRunProgramFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilenameinControl As String) As Long


'/*************************************************************
'˵��: ���ص�ram������
'����: ������handle �ļ���
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownProgramToRamAndRun(SMCHANDLE handle, const char* pfilename);
Declare Function SMCDownProgramToRamAndRun Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long


'/*************************************************************
'˵��: ���ص�ram������
'����: ������handle �ڴ�buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownMemProgramToRamAndRun(SMCHANDLE handle, const char* pbuffer, uint32 buffsize);
Declare Function SMCDownMemProgramToRamAndRun Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long) As Long


'/*************************************************************
'˵��: �ϴ������ļ�
'����: ������handle �ڴ�buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCUpProgram(SMCHANDLE handle, const char* pfilename, const char* pfilenameinControl);
Declare Function SMCUpProgram Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String, ByVal pfilenameinControl As String) As Long



'/*************************************************************
'˵��: �ϴ������ļ�
'����: ������handle �ڴ�buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCUpProgramToMem(SMCHANDLE handle, char* pbuffer, uint32 buffsize, char* pfilenameinControl, uint32* puifilesize);
Declare Function SMCUpProgramToMem Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long, ByVal pfilenameinControl As String, ByRef puifilesize As Long) As Long

'
'/*************************************************************
'˵��: ��ͣ
'���룺������handle �ļ����� ��ΪNULL��ʱ������ȱʡ�ļ�
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCPause(SMCHANDLE handle);
Declare Function SMCPause Lib "smc6x.dll" (ByVal handle As Long) As Long

'/*************************************************************
'˵��: ֹͣ
'���룺������handle �ļ����� ��ΪNULL��ʱ������ȱʡ�ļ�
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCStop(SMCHANDLE handle);
Declare Function SMCStop Lib "smc6x.dll" (ByVal handle As Long) As Long

'/*************************************************************
'˵��: ������ʱ�ļ�
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCRunTempFile(SMCHANDLE handle);
Declare Function SMCRunTempFile Lib "smc6x.dll" (ByVal handle As Long) As Long

'/*************************************************************
'˵��: ��ȡʣ��ռ�
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCCheckRemainProgramSpace(SMCHANDLE handle, uint32 * pRemainSpaceInKB);
Declare Function SMCCheckRemainProgramSpace Lib "smc6x.dll" (ByVal handle As Long, ByRef pRemainSpaceInKB As Long) As Long


'/*************************************************************
'˵��: ��ȡ����ֹͣԭ��
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCCheckProgramStopReason(SMCHANDLE handle, uint32 * pStopReason);
Declare Function SMCCheckProgramStopReason Lib "smc6x.dll" (ByVal handle As Long, ByRef pStopReason As Long) As Long


'/*************************************************************
'˵��: ��ȡ����ǰ��
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCGetCurRunningLine(SMCHANDLE handle, uint32 * pLineNum);
Declare Function SMCGetCurRunningLine Lib "smc6x.dll" (ByVal handle As Long, ByRef pLineNum As Long) As Long
'/*************************************************************
'˵�������õ������У����ʵʱ�޸�״̬��������ʧ
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCSetStepRun(SMCHANDLE handle, uint8 bifStep);
Declare Function SMCSetStepRun Lib "smc6x.dll" (ByVal handle As Long, ByVal bifStep As Byte) As Long

'/*************************************************************
'˵�������ÿ��ߣ����ʵʱ�޸�״̬��������ʧ
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCSetRunNoIO(SMCHANDLE handle, uint8 bifVainRun);
Declare Function SMCSetRunNoIO Lib "smc6x.dll" (ByVal handle As Long, ByVal bifVainRun As Byte) As Long



'/*************************************************************
'˵��: ��ȡ����
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCGetRunningOption(SMCHANDLE handle, uint8* bifStep, uint8* bifVainRun);
Declare Function SMCGetRunningOption Lib "smc6x.dll" (ByVal handle As Long, ByRef bifStep As Byte, ByRef bifVainRun As Byte) As Long


'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCContinueRun(SMCHANDLE handle);
Declare Function SMCContinueRun Lib "smc6x.dll" (ByVal handle As Long) As Long


'/*************************************************************
'˵��: ����ļ��Ƿ����
'���룺������handle ���������ļ�����������չ
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCCheckProgramFile(SMCHANDLE handle, const char* pfilenameinControl, uint8 *pbIfExist, uint32 *pFileSize);
Declare Function SMCCheckProgramFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilenameinControl As String, ByRef pbIfExist As Byte, ByRef pFileSize As Long) As Long


'/*************************************************************
'˵�������ҿ������ϵ��ļ��� �ļ���Ϊ�ձ�ʾ�ļ���������
'���룺������handle ���������ļ�����������չ
'���:  �Ƿ���� �ļ���С
'����ֵ: ������
'*************************************************************/
'int32 SMCFindFirstProgramFile(SMCHANDLE handle, char* pfilenameinControl, uint32 *pFileSize);
Declare Function SMCFindFirstProgramFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilenameinControl As String, ByRef pFileSize As Long) As Long


'/*************************************************************
'˵�������ҿ������ϵ��ļ��� �ļ���Ϊ�ձ�ʾ�ļ���������
'���룺������handle ���������ļ�����������չ
'���:  �Ƿ���� �ļ���С
'����ֵ: ������
'*************************************************************/
'int32 SMCFindNextProgramFile(SMCHANDLE handle, char* pfilenameinControl, uint32 *pFileSize);
Declare Function SMCFindNextProgramFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilenameinControl As String, ByRef pFileSize As Long) As Long

'/*************************************************************
'˵��: ���ҿ������ϵĵ�ǰ�ļ�
'���룺������handle ���������ļ�����������չ
'���:  �Ƿ���� �ļ���С(��ʱ��֧��)
'����ֵ: ������
'*************************************************************/
'int32 SMCGetCurProgramFile(SMCHANDLE handle, char* pfilenameinControl, uint32 *pFileSize);
Declare Function SMCGetCurProgramFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilenameinControl As String, ByRef pFileSize As Long) As Long

'/*************************************************************
'˵��: ɾ���������ϵ��ļ�
'���룺������handle ���������ļ�����������չ
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDeleteProgramFile(SMCHANDLE handle, const char* pfilenameinControl);
Declare Function SMCDeleteProgramFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilenameinControl As String) As Long
'/*************************************************************
'˵��: ɾ���������ϵ��ļ�
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCRemoveAllProgramFiles(SMCHANDLE handle);
Declare Function SMCRemoveAllProgramFiles Lib "smc6x.dll" (ByVal handle As Long) As Long




''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'config controller
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'/*************************************************************
'˵��: ͨ�õ��ַ����ӿ�
'���룺������handle �����ַ����������ַ����� �����ַ�������, ������ҪӦ��ʱ����uiResponseLength = 0
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCCommand(SMCHANDLE handle, const char* pszCommand, char* psResponse, uint32 uiResponseLength);
Declare Function SMCCommand Lib "smc6x.dll" (ByVal handle As Long, ByVal pszCommand As String, ByVal psResponse As String, ByVal pFileSize As Long) As Long

'/*************************************************************
'˵��: ��ǰ���ô���
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCBurnSetting(SMCHANDLE handle);
Declare Function SMCBurnSetting Lib "smc6x.dll" (ByVal handle As Long) As Long

'/*************************************************************
'˵��: ���������ļ�
'����: ������handle �ļ���
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownSetting(SMCHANDLE handle, const char* pfilename);
Declare Function SMCDownSetting Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long


'/*************************************************************
'˵��: ���������ļ�
'����: ������handle buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownMemSetting(SMCHANDLE handle, const char* pbuffer, uint32 buffsize);
Declare Function SMCDownMemSetting Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long) As Long


'/*************************************************************
'˵��: �ϴ�����
'����: ������handle �ڴ�buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCUpSetting(SMCHANDLE handle, const char* pfilename);
Declare Function SMCUpSetting Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long
'/*************************************************************
'˵��: �ϴ�����
'���룺������handle �ڴ�buff ����ʵ�ʵ��ļ�����
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCUpSettingToMem(SMCHANDLE handle, char* pbuffer, uint32 buffsize, uint32* puifilesize);
Declare Function SMCUpSettingToMem Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long, puifilesize As Long) As Long
'/*************************************************************
'˵��: ���������ļ�
'����: ������handle �ļ���
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownDefaultSetting(SMCHANDLE handle, const char* pfilename);
Declare Function SMCDownDefaultSetting Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long
'/*************************************************************
'˵�������������ļ�, �ı��ļ��ĳ�����strlen ����
'����: ������handle buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCDownMemDefaultSetting(SMCHANDLE handle, const char* pbuffer, uint32 buffsize);
Declare Function SMCDownMemDefaultSetting Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long) As Long

'/*************************************************************
'˵��: �ϴ�����
'����: ������handle �ڴ�buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCUpDefaultSetting(SMCHANDLE handle, const char* pfilename);
Declare Function SMCUpDefaultSetting Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long

'/*************************************************************
'˵��: �ϴ�����
'����: ������handle �ڴ�buff
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCUpDefaultSettingToMem(SMCHANDLE handle, char* pbuffer, uint32 buffsize, uint32* puifilesize);
Declare Function SMCUpDefaultSettingToMem Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long, puifilesize As Long) As Long
'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCSetIpAddr(SMCHANDLE handle, const char* sIpAddr, const char* sGateAddr, const char* sMask, uint8 bifdhcp);
Declare Function SMCSetIpAddr Lib "smc6x.dll" (ByVal handle As Long, ByVal sIpAddr As String, ByVal sGateAddr As String, ByVal sMask As String, ByVal bifdhcp As Byte) As Long
'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCGetIpAddr(SMCHANDLE handle, char* sIpAddr, char* sGateAddr, char* sMask, uint8 *pbifdhcp);
Declare Function SMCGetIpAddr Lib "smc6x.dll" (ByVal handle As Long, ByVal sIpAddr As String, ByVal sGateAddr As String, ByVal sMask As String, ByRef bifdhcp As Byte) As Long


'/*************************************************************
'˵������ȡ��ǰ��������IP��ַ, ע��:������dhcp�Ժ����õ�IP��ʵ�ʵĲ�һ�¡�
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCGetCurIpAddr(SMCHANDLE handle, char* sIpAddr);
Declare Function SMCGetCurIpAddr Lib "smc6x.dll" (ByVal handle As Long, ByVal sIpAddr As String) As Long
'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCSetZeroSpeed(SMCHANDLE handle, uint8 iaxis, uint32 uiSpeed);
Declare Function SMCSetZeroSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal uiSpeed As Long) As Long

'
'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCGetZeroSpeed(SMCHANDLE handle, uint8 iaxis, uint32* puiSpeed);
Declare Function SMCGetZeroSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef puiSpeed As Long) As Long
'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCSetLocateSpeed(SMCHANDLE handle, uint8 iaxis, uint32 uiSpeed);
Declare Function SMCSetLocateSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal uiSpeed As Long) As Long

'/*************************************************************
'˵��: ��������
'����: ������handle
'���:
'����ֵ: ������
'*************************************************************/
'int32 SMCGetLocateSpeed(SMCHANDLE handle, uint8 iaxis, uint32* puiSpeed);
Declare Function SMCGetLocateSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef puiSpeed As Long) As Long

Declare Function SMCSetLocateStartSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal uiSpeed As Long) As Long

'int32 SMCGetLocateStartSpeed(SMCHANDLE handle, uint8 iaxis, uint32* puiSpeed);
Declare Function SMCGetLocateStartSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef puiSpeed As Long) As Long
'int32 SMCSetLocateAcceleration(SMCHANDLE handle, uint8 iaxis, uint32 uiValue);
Declare Function SMCSetLocateAcceleration Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal uiValue As Long) As Long
'int32 SMCGetLocateAcceleration(SMCHANDLE handle, uint8 iaxis, uint32* puiValue);
Declare Function SMCGetLocateAcceleration Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef puiValue As Long) As Long
'int32 SMCSetLocateDeceleration(SMCHANDLE handle, uint8 iaxis, uint32 uiValue);
Declare Function SMCSetLocateDeceleration Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal uiValue As Long) As Long
'int32 SMCGetLocateDeceleration(SMCHANDLE handle, uint8 iaxis, uint32* puiValue);
Declare Function SMCGetLocateDeceleration Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef puiValue As Long) As Long
'int32 SMCSetUnitPulses(SMCHANDLE handle, uint8 iaxis, uint32 uiValue);
Declare Function SMCSetUnitPulses Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal uiValue As Long) As Long
'int32 SMCGetUnitPulses(SMCHANDLE handle, uint8 iaxis, uint32* puiValue);
Declare Function SMCGetUnitPulses Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef puiValue As Long) As Long
'int32 SMCSetVectStartSpeed(SMCHANDLE handle, uint32 uiValue);
Declare Function SMCSetVectStartSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal uiValue As Long) As Long
'int32 SMCGetVectStartSpeed(SMCHANDLE handle, uint32* puiValue);
Declare Function SMCGetVectStartSpeed Lib "smc6x.dll" (ByVal handle As Long, ByRef puiValue As Long) As Long
'int32 SMCSetVectSpeed(SMCHANDLE handle, uint32 uiValue);
Declare Function SMCSetVectSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal uiValue As Long) As Long
'int32 SMCGetVectSpeed(SMCHANDLE handle, uint32* puiValue);
Declare Function SMCGetVectSpeed Lib "smc6x.dll" (ByVal handle As Long, ByRef puiValue As Long) As Long
'int32 SMCSetVectAcceleration(SMCHANDLE handle, uint32 uiValue);
Declare Function SMCSetVectAcceleration Lib "smc6x.dll" (ByVal handle As Long, ByVal uiValue As Long) As Long
'int32 SMCGetVectAcceleration(SMCHANDLE handle, uint32* puiValue);
Declare Function SMCGetVectAcceleration Lib "smc6x.dll" (ByVal handle As Long, ByRef puiValue As Long) As Long
'int32 SMCSetVectDeceleration(SMCHANDLE handle, uint32 uiValue);
Declare Function SMCSetVectDeceleration Lib "smc6x.dll" (ByVal handle As Long, ByVal uiValue As Long) As Long
'int32 SMCGetVectDeceleration(SMCHANDLE handle, uint32* puiValue);
Declare Function SMCGetVectDeceleration Lib "smc6x.dll" (ByVal handle As Long, ByRef puiValue As Long) As Long


'int32 SMCPMove(SMCHANDLE handle, uint8 iaxis, double dlength, uint8 bIfAbs);
Declare Function SMCPMove Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal dlength As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCPMovePluses(SMCHANDLE handle, uint8 iaxis, int32 ilength, uint8 bIfAbs);
Declare Function SMCPMovePluses Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal ilength As Long, ByVal bIfAbs As Byte) As Long
'int32 SMCVMove(SMCHANDLE handle, uint8 iaxis, uint8 bIfPositiveDir);
Declare Function SMCVMove Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal bIfPositiveDir As Byte) As Long
'int32 SMCPMoveList(SMCHANDLE handle,uint8 itotalaxises, uint8 *puilineaxislist, uint32 uisteps, double *pDistanceList, uint8 bIfAbs);
Declare Function SMCPMoveList Lib "smc6x.dll" (ByVal handle As Long, ByVal itotalaxises As Byte, ByRef puilineaxislist As Byte, ByVal uisteps As Long, pDistanceList As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCCheckDown(SMCHANDLE handle,uint8 iaxis, uint8* pbIfDown);
Declare Function SMCCheckDown Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByRef pbIfDown As Byte) As Long
'int32 SMCHomeMove(SMCHANDLE handle,uint8 iaxis);
Declare Function SMCHomeMove Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte) As Long
'int32 SMCIfHomeMoveing(SMCHANDLE handle,uint8 iaxis, uint8* pbIfHoming);
Declare Function SMCIfHomeMoveing Lib "smc6x.dll" (ByVal handle As Long, pbIfHoming As Byte) As Long
'int32 SMCDecelStop(SMCHANDLE handle,uint8 iaxis);
Declare Function SMCDecelStop Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte) As Long
'int32 SMCImdStop(SMCHANDLE handle,uint8 iaxis);
Declare Function SMCImdStop Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte) As Long
'int32 SMCEmgStop(SMCHANDLE handle);
Declare Function SMCEmgStop Lib "smc6x.dll" (ByVal handle As Long) As Long
'int32 SMCChangeSpeed(SMCHANDLE handle,uint8 iaxis, double dspeed);
Declare Function SMCChangeSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal dspeed As Double) As Long
'int32 SMCGetPosition(SMCHANDLE handle,uint8 iaxis, double* pposition);
Declare Function SMCGetPosition Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pposition As Double) As Long
'int32 SMCGetWorkPosition(SMCHANDLE handle,uint8 iaxis, double* pposition);
Declare Function SMCGetWorkPosition Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pposition As Double) As Long
'int32 SMCGetPositionPulses(SMCHANDLE handle,uint8 iaxis, int32* pposition);
Declare Function SMCGetPositionPulses Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pposition As Long) As Long
'int32 SMCGetWorkOriginPosition(SMCHANDLE handle, uint8 iaxis, double* pposition);
Declare Function SMCGetWorkOriginPosition Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pposition As Double) As Long
'int32 SMCSetPosition(SMCHANDLE handle,uint8 iaxis, double dposition);
Declare Function SMCSetPosition Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal dposition As Double) As Long
'int32 SMCSetPositionPulses(SMCHANDLE handle,uint8 iaxis, int32 iposition);
Declare Function SMCSetPositionPulses Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal iposition As Long) As Long
'int32 SMCWaitDown(SMCHANDLE handle,uint8 iaxis);
Declare Function SMCWaitDown Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte) As Long
'int32 SMCWaitPoint(SMCHANDLE handle,uint8 iaxis, double dpos);
Declare Function SMCWaitPoint Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal dpos As Double) As Long
'int32 SMCHandWheelSet(SMCHANDLE handle,uint8 iaxis, uint16 imulti, uint8 bifDirReverse);
Declare Function SMCHandWheelSet Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal imulti As Integer, ByVal bifDirReverse As Byte) As Long
'int32 SMCHandWheelMove(SMCHANDLE handle,uint8 iaxis, uint8 bifenable);
Declare Function SMCHandWheelMove Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal bifenable As Byte) As Long
'int32 SMCVectMoveStart(SMCHANDLE handle);
Declare Function SMCVectMoveStart Lib "smc6x.dll" (ByVal handle As Long) As Long
'int32 SMCVectMoveEnd(SMCHANDLE handle);
Declare Function SMCVectMoveEnd Lib "smc6x.dll" (ByVal handle As Long) As Long
'int32 SMCGetVectMoveState(SMCHANDLE handle, uint8 *pState);
Declare Function SMCGetVectMoveState Lib "smc6x.dll" (ByVal handle As Long, pState As Byte) As Long
'int32 SMCGetVectMoveRemainSpace(SMCHANDLE handle, uint32 *pSpace);
Declare Function SMCGetVectMoveRemainSpace Lib "smc6x.dll" (ByVal handle As Long, pSpace As Long) As Long
'int32 SMCVectMoveLine1(SMCHANDLE handle, uint8 iaxis, double Distance, double dspeed, uint8 bIfAbs);
Declare Function SMCVectMoveLine1 Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal Distance As Double, ByVal dspeed As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCVectMoveLine2(SMCHANDLE handle, uint8 iaxis1, double Distance1, uint8 iaxis2, double Distance2, double dspeed, uint8 bIfAbs);
Declare Function SMCVectMoveLine2 Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis1 As Byte, ByVal Distance1 As Double, ByVal iaxis2 As Byte, ByVal Distance2 As Double, ByVal dspeed As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCVectMoveLineN(SMCHANDLE handle, uint8 itotalaxis, uint8* piaxisList, double* DistanceList, double dspeed, uint8 bIfAbs);
Declare Function SMCVectMoveLineN Lib "smc6x.dll" (ByVal handle As Long, ByVal itotalaxis As Byte, piaxisList As Byte, DistanceList As Double, ByVal dspeed As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCVectMoveMultiLine2(SMCHANDLE handle, uint8 iaxis1, uint8 iaxis2, uint16 uiSectes, double* DistanceList, double* dspeedList, uint8 bIfAbs);
Declare Function SMCVectMoveMultiLine2 Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis1 As Byte, ByVal iaxis2 As Byte, ByVal uiSectes As Integer, DistanceList As Double, pspeedList As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCVectMoveMultiLineN(SMCHANDLE handle, uint8 itotalaxis, uint8* piaxisList, uint16 uiSectes,double* DistanceList, double* dspeedList, uint8 bIfAbs);
Declare Function SMCVectMoveMultiLineN Lib "smc6x.dll" (ByVal handle As Long, ByVal itotalaxis As Byte, piaxisList As Byte, ByVal uiSectes As Integer, DistanceList As Double, dspeedList As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCVectMoveArc(SMCHANDLE handle, uint8 iaxis1, uint8 iaxis2, double Distance1, double Distance2, double Center1, double Center2, uint8 bIfAnticlockwise, double dspeed, uint8 bIfAbs);
Declare Function SMCVectMoveArc Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis1 As Byte, ByVal iaxis2 As Byte, ByVal Distance1 As Double, ByVal Distance2 As Double, ByVal Center1 As Double, ByVal Center2 As Double, ByVal bIfAnticlockwise As Byte, ByVal dspeed As Double, ByVal bIfAbs As Byte) As Long
'int32 SMCVectMoveSetSpeedLimition(SMCHANDLE handle, double dspeed);
Declare Function SMCVectMoveSetSpeedLimition Lib "smc6x.dll" (ByVal handle As Long, ByVal dspeed As Double) As Long
'int32 SMCWaitVectLength(SMCHANDLE handle, double vectlength);
Declare Function SMCWaitVectLength Lib "smc6x.dll" (ByVal handle As Long, ByVal vectlength As Double) As Long
'int32 SMCGetCurRunVectLength(SMCHANDLE handle, double* pvectlength);
Declare Function SMCGetCurRunVectLength Lib "smc6x.dll" (ByVal handle As Long, pvectlength As Double) As Long
'int32 SMCGetCurSpeed(SMCHANDLE handle, uint8 iaxis, double* pspeed);
Declare Function SMCGetCurSpeed Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pspeed As Double) As Long
'int32 SMCVectMovePause(SMCHANDLE handle);
Declare Function SMCVectMovePause Lib "smc6x.dll" (ByVal handle As Long) As Long
'int32 SMCVectMoveStop(SMCHANDLE handle);
Declare Function SMCVectMoveStop Lib "smc6x.dll" (ByVal handle As Long) As Long
'int32 SMCAxisPause(SMCHANDLE handle, uint8 iaxis);
Declare Function SMCAxisPause Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte) As Long
'int32 SMCWriteLed(SMCHANDLE handle, uint16 iLedNum, uint8 bifLighten);
Declare Function SMCWriteLed Lib "smc6x.dll" (ByVal handle As Long, ByVal iLedNum As Integer, ByVal bifLighten As Byte) As Long
'int32 SMCWriteOutBit(SMCHANDLE handle, uint16 ioNum, uint8 IoState);
Declare Function SMCWriteOutBit Lib "smc6x.dll" (ByVal handle As Long, ByVal ioNum As Integer, ByVal IoState As Byte) As Long
'int32 SMCReadInBit(SMCHANDLE handle, uint16 ioNum, uint8* pIoState);
Declare Function SMCReadInBit Lib "smc6x.dll" (ByVal handle As Long, ByVal ioNum As Integer, pIoState As Byte) As Long
'int32 SMCReadOutBit(SMCHANDLE handle, uint16 ioNum, uint8* pIoState);
Declare Function SMCReadOutBit Lib "smc6x.dll" (ByVal handle As Long, ByVal ioNum As Integer, pIoState As Byte) As Long
'int32 SMCWriteOutPort(SMCHANDLE handle, uint32 IoMask, uint32 IoState);
Declare Function SMCWriteOutPort Lib "smc6x.dll" (ByVal handle As Long, ByVal IoMask As Long, ByVal IoState As Long) As Long
'int32 SMCReadInPort(SMCHANDLE handle, uint32* pIoState);
Declare Function SMCReadInPort Lib "smc6x.dll" (ByVal handle As Long, pIoState As Long) As Long
'int32 SMCReadOutPort(SMCHANDLE handle, uint32* pIoState);
Declare Function SMCReadOutPort Lib "smc6x.dll" (ByVal handle As Long, pIoState As Long) As Long
'int32 SMCReadAlarmState(SMCHANDLE handle, uint8 iaxis, uint8* pIoState);
Declare Function SMCReadAlarmState Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pIoState As Byte) As Long
'int32 SMCReadHomeState(SMCHANDLE handle, uint8 iaxis, uint8* pIoState);
Declare Function SMCReadHomeState Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pIoState As Byte) As Long
'int32 SMCReadEMGState(SMCHANDLE handle, uint8* pIoState);
Declare Function SMCReadEMGState Lib "smc6x.dll" (ByVal handle As Long, pIoState As Byte) As Long
'int32 SMCReadHandWheelStates(SMCHANDLE handle, uint8 iaxis, uint8* pIoAState, uint8* pIoBState);
Declare Function SMCReadHandWheelStates Lib "smc6x.dll" (ByVal handle As Long, pIoState As Byte, pIoBState As Byte) As Long
'int32 SMCReadElStates(SMCHANDLE handle, uint8 iaxis, uint8* pElDecState, uint8* pElPlusState);
Declare Function SMCReadElStates Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pElDecState As Byte, pElPlusState As Byte) As Long
'int32 SMCReadSdStates(SMCHANDLE handle, uint8 iaxis, uint8* pIoState);
Declare Function SMCReadSdStates Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pIoState As Byte) As Long
'int32 SMCReadInpStates(SMCHANDLE handle, uint8 iaxis, uint8* pIoState);
Declare Function SMCReadInpStates Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pIoState As Byte) As Long
'int32 SMCReadAxisStates(SMCHANDLE handle, uint8 iaxis, struct_AxisStates* pAxisState);
Declare Function SMCReadAxisStates Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, pIoState As struct_AxisStates) As Long
'int32 SMCWritePwmDuty(SMCHANDLE handle, uint8 ichannel, float fDuty);
Declare Function SMCWritePwmDuty Lib "smc6x.dll" (ByVal handle As Long, ByVal ichannel As Byte, ByVal fDuty As Single) As Long
'int32 SMCWritePwmFreqency(SMCHANDLE handle, uint8 ichannel, float fFre);
Declare Function SMCWritePwmFreqency Lib "smc6x.dll" (ByVal handle As Long, ByVal ichannel As Byte, ByVal fFre As Single) As Long
'int32 SMCWriteDaOut(SMCHANDLE handle, uint8 ichannel, float fLevel);
Declare Function SMCWriteDaOut Lib "smc6x.dll" (ByVal handle As Long, ByVal ichannel As Byte, ByVal fLevel As Single) As Long
'int32 SMCReadPwmDuty(SMCHANDLE handle, uint8 ichannel, float* fDuty);
Declare Function SMCReadPwmDuty Lib "smc6x.dll" (ByVal handle As Long, ByVal ichannel As Byte, fDuty As Single) As Long
'int32 SMCReadPwmFreqency(SMCHANDLE handle, uint8 ichannel, float* fFre);
Declare Function SMCReadPwmFreqency Lib "smc6x.dll" (ByVal handle As Long, ByVal ichannel As Byte, fFre As Single) As Long
'int32 SMCReadDaOut(SMCHANDLE handle, uint8 ichannel, float* fLevel);
Declare Function SMCReadDaOut Lib "smc6x.dll" (ByVal handle As Long, ByVal ichannel As Byte, fLevel As Single) As Long
'int32 SMCGetClientId(SMCHANDLE handle,uint16 *pId);
Declare Function SMCGetClientId Lib "smc6x.dll" (ByVal handle As Long, pId As Integer) As Long
 'int32 SMCGetSoftwareId(SMCHANDLE handle,uint16 *pId);
Declare Function SMCGetSoftwareId Lib "smc6x.dll" (ByVal handle As Long, pId As Integer) As Long
'int32 SMCGetHardwareId(SMCHANDLE handle,uint16 *pId);
Declare Function SMCGetHardwareId Lib "smc6x.dll" (ByVal handle As Long, pId As Integer) As Long
'int32 SMCGetSoftwareVersion(SMCHANDLE handle,uint32 *pVersion);
Declare Function SMCGetSoftwareVersion Lib "smc6x.dll" (ByVal handle As Long, pVersion As Integer) As Long
'int32 SMCUpPasswordFile(SMCHANDLE handle, const char* pfilename);
Declare Function SMCUpPasswordFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long
'int32 SMCUpPasswordFileToMem(SMCHANDLE handle, char* pbuffer, uint32 buffsize, uint32* puifilesize);
Declare Function SMCUpPasswordFileToMem Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, puifilesize As Long) As Long
'int32 SMCDownPasswordFile(SMCHANDLE handle, const char* pfilename);
Declare Function SMCDownPasswordFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pfilename As String) As Long
'int32 SMCDownMemPasswordFile(SMCHANDLE handle, const char* pbuffer, uint32 buffsize);
Declare Function SMCDownMemPasswordFile Lib "smc6x.dll" (ByVal handle As Long, ByVal pbuffer As String, ByVal buffsize As Long) As Long
'int32 SMCEnterSetPassword(SMCHANDLE handle, uint32 uipassword);
Declare Function SMCEnterSetPassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCEnterEditPassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCEnterSuperPassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCEnterTimePassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCClearEnteredPassword Lib "smc6x.dll" (ByVal handle As Long) As Long
Declare Function SMCModifySetPassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCModifyEditPassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCModifySuperPassword Lib "smc6x.dll" (ByVal handle As Long, ByVal uipassword As Long) As Long
Declare Function SMCGetTrialCondition Lib "smc6x.dll" (ByVal handle As Long, pRunHours As Long, pbifTimeLocked As Integer, pbAlreadyEnterdTimePasswordNum As Integer) As Long
Declare Function SMCModbus_Set0x Lib "smc6x.dll" (ByVal handle As Long, ByVal start As Integer, ByVal inum As Integer, pdata As Byte) As Long
Declare Function SMCModbus_Get0x Lib "smc6x.dll" (ByVal handle As Long, ByVal start As Integer, ByVal inum As Integer, pdata As Byte) As Long
Declare Function SMCModbus_Get4x Lib "smc6x.dll" (ByVal handle As Long, ByVal start As Integer, ByVal inum As Integer, pdata As Byte) As Long
Declare Function SMCModbus_Set4x Lib "smc6x.dll" (ByVal handle As Long, ByVal start As Integer, ByVal inum As Integer, pdata As Byte) As Long
Declare Function SMCGetErrcodeDescription Lib "smc6x.dll" (ByVal ierrcode As Long) As String
Declare Function SMCCheckProgramSyntax Lib "smc6x.dll" (ByVal sin As String, ByVal sError As String) As Long
Declare Function SMCConfigHomeMode Lib "smc6x.dll" (ByVal handle As Long, ByVal iaxis As Byte, ByVal home_dir As Byte, ByVal vel As Double, ByVal mode As Byte) As Long


































''�������������ϸ񱣳�һ����
            
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''                                 DMC5480 V1.0 end of module                       '''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

