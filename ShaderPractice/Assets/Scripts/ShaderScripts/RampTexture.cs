using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;

public class RampTexture : MonoBehaviour
{
    public List<Transform> ListButton;
    public Transform ButtonParent;
    public MeshRenderer mesh;

    private const string path = "/Resources/Textures";

    // Start is called before the first frame update
    void Start()
    {
        Init();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Init()
    {
        for(int i = 0 , ci = ListButton.Count; i < ci; i++)
        {
            ListButton[i].GetComponent<Button>().onClick.AddListener(ChangeTexture);
        }
    }

    private void ChangeTexture()
    {
        string textureName = EventSystem.current.currentSelectedGameObject.name;
        string dataPath = string.Format("{0}{1}/{2}", Application.dataPath, path, textureName);
        Texture texture = Resources.Load(dataPath) as Texture;
        mesh.materials[0].mainTexture = texture;
    }

}
