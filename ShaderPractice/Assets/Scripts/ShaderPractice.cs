using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;
using UnityEngine.EventSystems;

public class ShaderPractice : MonoBehaviour
{
    public GameObject ButtonTemplate;
    public Transform ParentTransform;
    public Transform LightTransform;

    //prefab路径
    private string prefabPath;
    //prefab信息
    private FileInfo[] prefabInfo;
    //当前展示的ShaderPrefab
    private GameObject currentShowedShader;

    // Start is called before the first frame update
    void Start()
    {
        Init();
    }

    // Update is called once per frame
    void Update()
    {
        LightTransform.Rotate(Vector3.up , 0.5f , Space.World);
    }

    private void Init()
    {
        //获取prefab文件夹路径
        prefabPath = string.Format("{0}/Resources/Prefabs", Application.dataPath);
        InitPrefabInfo();
        InitExampleButton();
    }

    private void InitPrefabInfo()
    {
        //获取所有Prefab文件信息
        DirectoryInfo dir = new DirectoryInfo(prefabPath);
        prefabInfo = dir.GetFiles("*.prefab");
    }

    private void InitExampleButton()
    {
        //生成按钮
        for(int i = 0,ci = prefabInfo.Length ; i < ci ; i++)
        {
            GameObject button = GameObject.Instantiate<GameObject>(ButtonTemplate, ParentTransform);
            button.SetActive(true);
            string prefabName = prefabInfo[i].Name;
            prefabName = prefabName.Substring(0, prefabName.Length - 7);
            button.name = prefabName;
            button.GetComponentInChildren<Text>().text = prefabName;
            button.transform.localPosition = new Vector3(90, -30 * (i + 1), 0);
            button.GetComponent<Button>().onClick.AddListener(SelectShader);
        }
    }

    public void SelectShader()
    {
        if(null != currentShowedShader)
        {
            Destroy(currentShowedShader);
        }
        string prefabName = EventSystem.current.currentSelectedGameObject.name;
        string path = string.Format("Prefabs/{0}", prefabName);
        GameObject prefab = Resources.Load<GameObject>(path);
        currentShowedShader = GameObject.Instantiate<GameObject>(prefab, transform);
    }
}
